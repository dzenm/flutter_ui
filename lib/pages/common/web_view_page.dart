import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/widgets/will_pop_scope_route.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// WebView内容改变时的回调
typedef WebViewCallback = void Function(dynamic data);

typedef ControllerCallback = void Function(WebViewController controller);

/// 通过WebView展示的页面
class WebViewPage extends StatefulWidget {
  final String title;
  final String url;

  WebViewPage({
    Key? key,
    required this.title,
    required this.url,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  String _title = '';
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScopeRoute(
      Scaffold(
        appBar: AppBar(title: Text(_title, style: TextStyle(color: Colors.white))),
        body: SafeArea(
          child: FlutterWebView(
            url: widget.url,
            onTitleChange: (result) => setState(() => _title = result),
            onControllerCallback: (WebViewController controller) {
              this._controller = controller;
            },
          ),
        ),
      ),
      behavior: BackBehavior.custom,
      onWillPop: () async {
        return _controller != null && !(await _controller!.canGoBack());
      },
    );
  }
}

/// 加载url的WebView
class FlutterWebView extends StatefulWidget {
  final String url;
  final WebViewCallback? onTitleChange;
  final ControllerCallback? onControllerCallback;

  FlutterWebView({
    Key? key,
    required this.url,
    this.onTitleChange,
    this.onControllerCallback,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FlutterWebViewState();
}

class _FlutterWebViewState extends State<FlutterWebView> {
  WebViewController? _controller;
  String _url = '';
  double _progressValue = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _url = widget.url;
  }

  JavascriptChannel _jsBridge(BuildContext context) => JavascriptChannel(
        name: 'jsBridge', // 必须与h5端的一致，不然收不到消息
        onMessageReceived: (JavascriptMessage message) async {
          debugPrint(message.message);
        },
      );

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      WebView(
        initialUrl: _url,
        //JS执行模式 是否允许JS执行
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          if (widget.onControllerCallback != null) {
            widget.onControllerCallback!(controller);
          }
          _controller = controller;
          if (_url.startsWith('http://') || _url.startsWith('https://')) {
            controller.loadUrl(_url);
          } else {
            _loadHtmlAssets(controller);
          }

          controller.canGoBack().then((value) {
            Log.d('WebView can go back: $value');
            if (value) {
              _controller!.goBack();
            }
          });
          controller.canGoForward().then((value) {
            Log.d('WebView can go forward: $value');
          });
          controller.currentUrl().then((value) {
            Log.d('WebView current url: $value');
          });
        },
        onPageStarted: (url) {
          setState(() => _isLoading = true);
        },
        onPageFinished: (url) {
          setState(() => _isLoading = false);
          //调用JS得到实际高度
          _controller?.evaluateJavascript("document.documentElement.clientHeight;").then((result) {
            setState(() {
              double _height = double.parse(result);
              Log.d("高度: $_height");
            });
          });
        },
        onProgress: (value) {
          setState(() => _progressValue = value / 100);
          _controller?.getTitle().then((value) {
            if (widget.onTitleChange != null) {
              widget.onTitleChange!(value);
            }
          });
        },
        onWebResourceError: (err) {
          setState(() => _isLoading = false);
        },
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('myapp://')) {
            Log.d('即将打开 ${request.url}');
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        javascriptChannels: [
          _jsBridge(context),
          JavascriptChannel(
            name: 'share',
            onMessageReceived: (JavascriptMessage message) {
              Log.d('参数： ${message.message}');
            },
          ),
        ].toSet(),
      ),
      Offstage(
        offstage: !_isLoading,
        child: LinearProgressIndicator(
          value: _progressValue, //0~1的浮点数，用来表示进度多少;如果 value 为 null 或空，则显示一个动画，否则显示一个定值
          backgroundColor: Colors.grey.shade200, //背景颜色
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), //进度颜色
        ),
      ),
    ]);
  }

  //加载本地文件
  void _loadHtmlAssets(WebViewController controller) async {
    String htmlPath = await rootBundle.loadString(widget.url);
    controller.loadUrl(Uri.dataFromString(
      htmlPath,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ).toString());
  }
}
