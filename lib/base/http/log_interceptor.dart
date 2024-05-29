import 'dart:convert';

import 'package:dio/dio.dart';

/// 网络请求[dio.Interceptor], 网络请求信息输出到控制台.
/// // log interceptor
//  dio.interceptors.add(LoggerInterceptor());
class LoggerInterceptor extends Interceptor {
  LogInterceptorConfig config;

  LoggerInterceptor({
    LogInterceptorConfig? config,
  }) : config = config ?? LogInterceptorConfig();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    handler.next(options);
  }

  /// 处理请求配置信息
  void _handleRequest(RequestOptions options) {
    bool existRequest = config.showRequest || config.showRequestHeader || config.showRequestBody;
    if (existRequest) {
      _printDecorateHead(title: 'Request ');
      _print('${options.method}  ${options.uri}');
    }

    //options.headers;
    if (config.showRequest) {
      Map<String, dynamic> map = {
        'responseType': options.responseType.toString(),
        'maxRedirects': options.maxRedirects,
        'listFormat': options.listFormat.toString(),
        'sendTimeout': options.sendTimeout,
        'connectTimeout': options.connectTimeout,
        'receiveTimeout': options.receiveTimeout,
        'followRedirects': options.followRedirects,
        'receiveDataWhenStatusError': options.receiveDataWhenStatusError,
        'extra': options.extra,
        'queryParameters': options.queryParameters,
      };
      _print(map);
    }
    if (config.showRequestHeader) {
      _print('headers:');
      _print(options.headers);
    }
    if (config.showRequestBody) {
      _print('body:');
      _print(options.data.toString(), isJson: true);
    }
    _printDecorateTail(needShow: existRequest);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    _handleRequest(response.requestOptions);
    _handleResponse(response);
    _renderCurlRepresentation(response.requestOptions);
    if (config.onCompleted != null) config.onCompleted!(response.statusCode == 200);
    handler.next(response);
  }

  /// 处理请求响应信息
  void _handleResponse(Response? response) {
    if (response == null) return;
    bool existResponse = config.showResponseHeader || config.showResponseBody;
    if (existResponse) {
      _printDecorateHead(title: 'Response');
      _print('${response.statusCode}  ${response.requestOptions.uri}  ${response.statusMessage}');
    }
    if (config.showResponseHeader) {
      _print('extra: ${response.extra}');
      if (response.isRedirect == true) {
        _print({'redirect': response.realUri});
      }
      _print('headers:');
      Map<String, dynamic> headers = {};
      response.headers.forEach((key, val) => headers[key] = val.join('\r\n\t'));
      _print(headers);
    }
    if (config.showResponseBody) {
      _print('body:');
      _print(response.toString(), isJson: true);
    }
    _printDecorateTail(needShow: existResponse);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (config.showError) {
      _handleRequest(err.requestOptions);
      _handleResponse(err.response);
      _handleError(err);
      _renderCurlRepresentation(err.requestOptions);
    }
    if (config.onCompleted != null) config.onCompleted!(false);
    handler.next(err);
  }

  /// 处理请求错误信息
  void _handleError(DioException err) {
    _printDecorateHead(title: 'DioError');
    _print('${err.error}');
    _printDecorateTail();
  }

  /// 打印curl请求
  void _renderCurlRepresentation(RequestOptions requestOptions) {
    if (!config.showCurlRequest) return;
    // add a breakpoint here so all errors can break
    String result = _cURLRepresentation(requestOptions);
    _logPrint('''
    $result''');
  }

  /// 将请求信息转化为curl字符串
  String _cURLRepresentation(RequestOptions options) {
    List<String> components = ['curl -i'];
    if (options.method.toUpperCase() != 'GET') {
      components.add('-X ${options.method}');
    }

    options.headers.forEach((k, v) {
      if (k != 'Cookie') {
        components.add('-H "$k: $v"');
      }
    });

    if (options.data != null) {
      // FormData can't be JSON-serialized, so keep only their fields attributes
      if (options.data is FormData) {
        options.data = Map.fromEntries(options.data.fields);
      }

      final data = json.encode(options.data).replaceAll('"', '\\"');
      components.add('-d "$data"');
    }

    components.add('"${options.uri.toString()}"');

    return components.join(' \\\n\t');
  }

  // 输出信息
  void _print(dynamic msg, {bool isJson = false}) {
    String interval = config.interval;
    if (msg is Map) {
      // 打印map
      msg.forEach((key, value) => _print('$interval$key: $value'));
    } else if (msg is String) {
      // 打印json
      if (isJson) {
        String jsonString = msg;
        // 此处在上传文件时，无法解析json，会报错
        try {
          if (config.isFormatJson) {
            jsonString = JsonEncoder.withIndent(interval).convert(json.decode(msg));
          }
        } catch (e) {
          jsonString = msg;
        }
        jsonString.split('\n').forEach((val) => _print('$interval$val'));
      } else {
        // 打印普通文本，修饰打印的日志样式
        String prefix = config.isDecorate && msg.isNotEmpty ? '║$interval' : '';
        String text = prefix + msg;
        _logPrint(text);
      }
    }
  }

  /// 装饰的头部
  void _printDecorateHead({bool needShow = true, String? title}) {
    if (!needShow) return;
    if (config.isDecorate) {
      _logPrint('╔══════════════════════════════ $title ════════════════════════════════════╗');
    } else {
      _logPrint('----------------------------------- $title -----------------------------------------');
    }
  }

  /// 装饰的尾部
  void _printDecorateTail({bool needShow = true}) {
    if (!needShow) return;
    if (config.isDecorate) {
      _logPrint('╚════════════════════════════════════════════════════════════════════════════╝');
    }
  }

  /// 日志打印
  void _logPrint(String msg) {
    if (config.logPrint == null) return;
    config.logPrint!(msg, tag: 'LoggerInterceptor');
  }
}

/// 日志拦截配置信息
class LogInterceptorConfig {
  /// 打印 request [Options]
  bool showRequest;

  /// 打印 request header [Options.headers]
  bool showRequestHeader;

  /// 打印 request data [Options.data]
  bool showRequestBody;

  /// 打印 [Response.data]
  bool showResponseBody;

  /// 打印 [Response.headers]
  bool showResponseHeader;

  /// 打印 error [DioException]
  bool showError;

  /// 打印curl请求
  bool showCurlRequest;

  /// format json
  bool isFormatJson;

  /// 添加装饰
  bool isDecorate;

  /// 缩进
  String interval;

  /// 请求完成回调，[success] 表示请求是否没有错误
  void Function(bool success)? onCompleted;

  /// Log printer; defaults print log to console.
  /// In flutter, you'd better use debugPrint.
  /// you can also write log in a file, for example:
  ///```dart
  ///  var file=File("./log.txt");
  ///  var sink=file.openWrite();
  ///  dio.interceptors.add(LoggerInterceptor(logPrint: sink.writeln));
  ///  ...
  ///  await sink.close();
  ///```
  void Function(Object object, {String tag})? logPrint;

  LogInterceptorConfig({
    this.showRequest = true,
    this.showRequestHeader = true,
    this.showRequestBody = true,
    this.showResponseHeader = true,
    this.showResponseBody = true,
    this.showError = true,
    this.showCurlRequest = true,
    this.isFormatJson = false,
    this.isDecorate = true,
    this.interval = '  ',
    this.onCompleted,
    this.logPrint,
  });
}
