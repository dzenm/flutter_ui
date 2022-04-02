import 'dart:convert';

import 'package:dio/dio.dart';

import '../log/log.dart';

///
/// Created by a0010 on 2022/3/22 09:38
/// 网络请求[dio.Interceptor], 网络请求信息输出到控制台.
/// log interceptor
/// dio.interceptors.add(LoggerInterceptor());
///
class LoggerInterceptor extends Interceptor {
  LoggerInterceptor({
    this.request = true,
    this.requestHeader = true,
    this.requestBody = true,
    this.responseHeader = true,
    this.responseBody = true,
    this.error = true,
    this.isFormat = true,
    this.isDecorate = true,
    this.logPrint = Log.d,
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
  ///  dio.interceptors.add(LogInterceptor(logPrint: sink.writeln));
  ///  ...
  ///  await sink.close();
  ///```
  void Function(Object object) logPrint;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    _handleRequest(options);
    handler.next(options);
  }

  void _handleRequest(RequestOptions options) {
    logPrint('╔══════════════════════════════ Request ═════════════════════════════════════╗');
    _print('${options.method}  ${options.uri}');

    //options.headers;
    if (request) {
      _printKV('responseType', options.responseType.toString());
      _printKV('maxRedirects', options.maxRedirects);
      _printKV('listFormat', options.listFormat.toString());
      _printKV('sendTimeout', options.sendTimeout);
      _printKV('connectTimeout', options.connectTimeout);
      _printKV('receiveTimeout', options.receiveTimeout);
      _printKV('followRedirects', options.followRedirects);
      _printKV('receiveDataWhenStatusError', options.receiveDataWhenStatusError);
      _printKV('extra', options.extra);
      _printKV('queryParameters', options.queryParameters);
    }
    if (requestHeader) {
      _print('headers:');
      options.headers.forEach((key, val) => _printKV('$key', val));
    }
    if (requestBody) {
      _print('body:');
      _printJson(options.data.toString());
    }
    logPrint('╚════════════════════════════════════════════════════════════════════════════╝');
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    _handleRequest(response.requestOptions);
    _handleResponse(response);
    handler.next(response);
  }

  void _handleResponse(Response response) {
    logPrint('╔══════════════════════════════ Response ════════════════════════════════════╗');
    _print('${response.statusCode}  ${response.requestOptions.uri}  ${response.statusMessage}');

    if (responseHeader) {
      _print('extra: ${response.extra}');
      if (response.isRedirect == true) {
        _print('redirect: ${response.realUri}');
      }

      _print('headers:');
      response.headers.forEach((key, val) => _printKV('$key', val.join('\r\n\t')));
    }
    if (responseBody) {
      _print('body:');
      _printJson(response.toString());
    }
    logPrint('╚════════════════════════════════════════════════════════════════════════════╝');
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    _handleError(err);
    handler.next(err);
  }

  void _handleError(DioError err) {
    if (error) {
      logPrint('╔══════════════════════════════ DioError ════════════════════════════════════╗');
      _print('$err');
      logPrint('╚════════════════════════════════════════════════════════════════════════════╝');
    }
  }

  /// 打印Json字符串
  void _printJson(String msg) => convert(msg).toString().split('\n').forEach((val) => _print('$interval$val'));

  /// 打印键值对
  void _printKV(String key, Object? val) => _print('$interval$key: $val');

  void _print(String msg) => logPrint((isDecorate && msg.isNotEmpty ? '║$interval' : '') + msg);

  /// 转成json格式字符串
  String convert(String msg) {
    try {
      return JsonEncoder.withIndent('  ').convert(json.decode(msg));
    } catch (e) {
      return msg;
    }
  }
}
