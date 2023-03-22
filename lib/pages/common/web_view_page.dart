import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../base/log/log.dart';
import '../../base/widgets/will_pop_view.dart';

/// WebView内容改变时的回调
typedef WebViewCallback = void Function(dynamic data);

typedef ControllerCallback = void Function(WebViewController controller);

/// 通过WebView展示的页面
class WebViewPage extends StatefulWidget {
  final String title;
  final String url;

  const WebViewPage({
    super.key,
    required this.title,
    required this.url,
  });

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
    return WillPopView(
      behavior: BackBehavior.custom,
      onWillPop: () async {
        return _controller != null && !(await _controller!.canGoBack());
      },
      child: Scaffold(
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
  double _progressValue = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _initWebViewController(widget.url);
  }

  void _initWebViewController(String url) {
    if (_controller == null) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              setState(() => _progressValue = progress / 100);
              _controller?.getTitle().then((value) {
                if (widget.onTitleChange != null) {
                  widget.onTitleChange!(value);
                }
              });
            },
            onPageStarted: (String url) {
              setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              setState(() => _isLoading = false);
              //调用JS得到实际高度
              _controller?.runJavaScript("document.documentElement.clientHeight;").then((result) {
                setState(() {
                  // double _height = double.parse(result);
                  // Log.d("高度: $_height");
                });
              });
            },
            onWebResourceError: (WebResourceError error) {
              setState(() => _isLoading = false);
            },
            onNavigationRequest: (NavigationRequest request) {
              if (request.url.startsWith('myapp://')) {
                Log.i('即将打开 ${request.url}');
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        );
    }
    if (_controller != null) {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        _controller!.loadRequest(Uri.parse(url));
      } else {
        _loadHtmlAssets(_controller!);
      }
      if (widget.onControllerCallback != null) {
        widget.onControllerCallback!(_controller!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      WebViewWidget(controller: _controller!),
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
    controller.loadRequest(Uri.dataFromString(
      htmlPath,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    ));
  }
}
