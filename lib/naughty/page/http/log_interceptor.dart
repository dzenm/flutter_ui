import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter_ui/http/log.dart';

/// 网络请求[dio.Interceptor], 网络请求信息输出.
class LogInterceptor extends dio.Interceptor {
  LogInterceptor({
    this.request = true,
    this.requestHeader = true,
    this.requestBody = true,
    this.responseHeader = true,
    this.responseBody = true,
    this.error = true,
    this.isFormat = true,
    this.logPrint = Log.httpLog,
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

  String interval = '  ';

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
  Future onRequest(dio.RequestOptions options) async {
    logPrint('');
    logPrint('******************** Request Start *********************');
    logPrint('${options.method}  ${options.uri}');

    //options.headers;
    if (request) {
      _printKV('responseType', options.responseType.toString());
      _printKV('followRedirects', options.followRedirects);
      _printKV('connectTimeout', options.connectTimeout);
      _printKV('sendTimeout', options.sendTimeout);
      _printKV('receiveTimeout', options.receiveTimeout);
      _printKV('receiveDataWhenStatusError', options.receiveDataWhenStatusError);
      _printKV('extra', options.extra);
    }
    if (requestHeader) {
      logPrint('headers:');
      options.headers.forEach((key, val) => _printKV('$key', val));
    }
    if (requestBody) {
      logPrint('body:');
      _printJson(options.data.toString());
    }

    logPrint('******************** Request End ***********************');
    return options;
  }

  @override
  Future onResponse(dio.Response response) async {
    logPrint('');
    logPrint('******************** Response Start ********************');
    logPrint('${response.statusCode}  ${response.request.uri}');

    if (responseHeader) {
      if (response.isRedirect == true) {
        _printKV('redirect', response.realUri);
      }

      logPrint('headers:');
      response.headers.forEach((key, val) => _printKV('$key', val.join('\r\n\t')));
    }
    if (responseBody) {
      logPrint('body:');
      _printJson(response.toString());
    }

    logPrint('******************** Response End **********************');
    logPrint('');
    return response;
  }

  @override
  Future onError(dio.DioError err) async {
    if (error) {
      logPrint('******************** DioError Start ********************');
      logPrint('$err');
      logPrint('******************** DioError End **********************');
    }
    return err;
  }

  /// 打印Json字符串
  void _printJson(String message) => convert(message).toString().split('\n').forEach((val) => logPrint('$interval$val'));

  /// 打印键值对
  void _printKV(String key, Object? val) => logPrint('$interval$key: $val');

  /// 转成json格式字符串
  String convert(String message) {
    try {
      return JsonEncoder.withIndent('  ').convert(json.decode(message));
    } catch (e) {
      return message;
    }
  }
}

enum Status {
  prepare,
  running,
  finished,
}

class HttpData {
  Status status;
  String method;
  String url;
  String duration;
  String time;
  String size;
  int running;

  HttpData({
    this.status = Status.prepare,
    this.method = '',
    this.url = '',
    this.duration = '',
    this.time = '',
    this.size = '',
    this.running = 0,
  });
}
