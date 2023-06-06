import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
    this.formatJson = false,
    this.decorate = true,
    this.interval = '  ',
    this.onCompleted,
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
  bool formatJson;

  /// 添加装饰
  bool decorate;

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
  void Function(Object object)? logPrint;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    handler.next(options);
  }

  /// 处理请求配置信息
  void _handleRequest(RequestOptions options) {
    bool existRequest = request || requestHeader || requestBody;
    if (existRequest) {
      if (decorate) {
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
      _print(map);
    }
    if (requestHeader) {
      _print('headers:');
      _print(options.headers);
    }
    if (requestBody) {
      _print('body:');
      _print(options.data.toString(), isJson: true);
    }
    if (existRequest && decorate) {
      _logPrint('╚════════════════════════════════════════════════════════════════════════════╝');
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    _handleRequest(response.requestOptions);
    _handleResponse(response);
    if (onCompleted != null) onCompleted!(response.statusCode == 200);
    handler.next(response);
  }

  /// 处理请求响应信息
  void _handleResponse(Response? response) {
    if (response == null) return;
    bool existResponse = responseHeader || responseBody;
    if (existResponse) {
      if (decorate) {
        _logPrint('╔══════════════════════════════ Response ════════════════════════════════════╗');
      } else {
        _logPrint('----------------------------------- Response -----------------------------------------');
      }
      _print('${response.statusCode}  ${response.requestOptions.uri}  ${response.statusMessage}');
    }
    if (responseHeader) {
      _print('extra: ${response.extra}');
      if (response.isRedirect == true) {
        _print({'redirect': response.realUri});
      }
      _print('headers:');
      Map<String, dynamic> headers = {};
      response.headers.forEach((key, val) => headers['$key'] = val.join('\r\n\t'));
      _print(headers);
    }
    if (responseBody) {
      _print('body:');
      _print(response.toString(), isJson: true);
    }
    if (existResponse && decorate) {
      _logPrint('╚════════════════════════════════════════════════════════════════════════════╝');
    }
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (error) {
      _handleRequest(err.requestOptions);
      _handleResponse(err.response);
      _handleError(err);
    }
    if (onCompleted != null) onCompleted!(false);
    handler.next(err);
  }

  /// 处理请求错误信息
  void _handleError(DioError err) {
    if (decorate) {
      _logPrint('╔══════════════════════════════ DioError ════════════════════════════════════╗');
    } else {
      _logPrint('----------------------------------- DioError -----------------------------------------');
    }
    _print('${err.error}');
    if (decorate) {
      _logPrint('╚════════════════════════════════════════════════════════════════════════════╝');
    }
  }

  // 输出信息
  void _print(dynamic msg, {bool isJson = false}) {
    if (msg is Map) {
      // 打印map
      msg.forEach((key, value) => _print('$interval$key: $value'));
    } else if (msg is String) {
      // 打印json
      if (isJson) {
        String jsonString = msg;
        try {
          if (formatJson) {
            jsonString = JsonEncoder.withIndent(interval).convert(json.decode(msg));
          }
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
        jsonString.split('\n').forEach((val) => _print('$interval$val'));
      } else {
        // 打印普通文本，修饰打印的日志样式
        String text = (decorate && msg.isNotEmpty ? '║$interval' : '') + msg;
        _logPrint(text);
      }
    }
  }

  /// 日志打印
  void _logPrint(String msg) {
    if (logPrint == null) return;
    logPrint!(msg);
  }
}
