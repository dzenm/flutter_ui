import 'dart:convert';

import 'package:dio/dio.dart';

import '../log/log.dart';
import '../utils/sp_util.dart';

/// 网络请求[dio.Interceptor], 网络请求信息输出到控制台.
/// // log interceptor
//  dio.interceptors.add(LoggerInterceptor());
class LoggerInterceptor extends Interceptor {
  LoggerInterceptor({
    this.request = true,
    this.requestHeader = true,
    this.requestBody = true,
    this.responseHeader = true,
    this.responseBody = true,
    this.error = true,
    this.isFormat = false,
    this.isDecorate = false,
    this.logPrint,
  });

  /// Print request [Options]
  bool request;

  /// Print request header [Options.headers]
  bool requestHeader;

  /// Print request data [Options.data]
  bool requestBody;

  /// Print [Response.data]
  bool responseBody;

  /// Print [Response.headers]
  bool responseHeader;

  /// Print error message
  bool error;

  /// format json
  bool isFormat;

  /// 添加装饰
  bool isDecorate;

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
  void Function(Object object)? logPrint;

  StringBuffer _logs = StringBuffer();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['authorization'] = SpUtil.getToken();
    handler.next(options);
  }

  /// 处理请求配置信息
  void _handleRequest(RequestOptions options) {
    bool existRequest = request || requestHeader || requestBody;
    if (existRequest) {
      if (isDecorate) {
        _logPrint('╔══════════════════════════════ Request ═════════════════════════════════════╗');
      } else {
        _logPrint('----------------------------------- Request ------------------------------------------');
      }
      _print('${options.method}  ${options.uri}');
    }

    //options.headers;
    if (request) {
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
      _printMap(map);
    }
    if (requestHeader) {
      _print('headers:');
      _printMap(options.headers);
    }
    if (requestBody) {
      _print('body:');
      _printJson(options.data.toString());
    }
    if (existRequest && isDecorate) {
      _logPrint('╚════════════════════════════════════════════════════════════════════════════╝');
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    _handleRequest(response.requestOptions);
    _handleResponse(response);
    handler.next(response);
  }

  /// 处理请求响应信息
  void _handleResponse(Response? response) {
    if (response == null) return;
    bool existResponse = responseHeader || responseBody;
    if (existResponse) {
      if (isDecorate) {
        _logPrint('╔══════════════════════════════ Response ════════════════════════════════════╗');
      } else {
        _logPrint('----------------------------------- Response -----------------------------------------');
      }
      _print('${response.statusCode}  ${response.requestOptions.uri}  ${response.statusMessage}');
    }
    if (responseHeader) {
      _print('extra: ${response.extra}');
      if (response.isRedirect == true) {
        _printMap({'redirect': response.realUri});
      }
      _print('headers:');
      Map<String, dynamic> headers = {};
      response.headers.forEach((key, val) => headers['$key'] = val.join('\r\n\t'));
      _printMap(headers);
    }
    if (responseBody) {
      _print('body:');
      _printJson(response.toString());
    }
    if (existResponse && isDecorate) {
      _logPrint('╚════════════════════════════════════════════════════════════════════════════╝');
    }
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    _handleRequest(err.requestOptions);
    _handleResponse(err.response);
    _handleError(err);
    _handleErrorLog(_logs.toString());
    handler.next(err);
  }

  /// 处理请求错误信息
  void _handleError(DioError err) {
    if (error) {
      if (isDecorate) {
        _logPrint('╔══════════════════════════════ DioError ════════════════════════════════════╗');
      } else {
        _logPrint('----------------------------------- DioError -----------------------------------------');
      }
      _print('${err.message}');
      if (isDecorate) {
        _logPrint('╚════════════════════════════════════════════════════════════════════════════╝');
      }
    }
  }

  /// 打印Json字符串
  void _printJson(String msg) {
    String jsonString = msg;
    try {
      if (isFormat) {
        /// 转成json格式字符串
        jsonString = JsonEncoder.withIndent('  ').convert(json.decode(msg));
      }
    } catch (e) {
      print(e);
    }
    List<String> list = jsonString.toString().split('\n');
    list.forEach((val) => _print('$interval$val'));
  }

  /// 打印map
  void _printMap(Map<String, dynamic> map) {
    map.forEach((key, value) => _print('$interval$key: $value'));
  }

  /// 打印日志，修饰打印的日志样式
  void _print(String msg) => _logPrint((isDecorate && msg.isNotEmpty ? '║$interval' : '') + msg);

  /// 日志打印
  void _logPrint(String msg) {
    if (logPrint != null) {
      // logPrint!(msg);
      _logs.write('\n$msg');
    }
  }

  void _handleErrorLog(String msg) {
    Log.d(msg);
  }
}
