import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import 'http_entity.dart';
import 'naughty.dart';

/// HTTP请求信息拦截
class HttpInterceptor extends Interceptor {
  final Map<RequestOptions, HTTPEntity> _cacheMap = {};
  final Map<String, int> _countMap = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    handler.next(options);

    HTTPEntity entity = HTTPEntity();
    // 请求的状态：初始为请求中
    entity.status = Status.running;
    // 请求的时间戳
    entity.duration = DateTime.now().millisecondsSinceEpoch.toString();
    // 请求的起始时间
    entity.time = DateFormat("HH:mm:ss SSS").format(DateTime.now());
    // 请求同一url的次数
    int? index = _countMap[options.path];
    _countMap[options.path] = (index ?? 0) + 1;
    entity.index = _countMap[options.path]!;
    _cacheMap[options] = entity;
    Naughty.instance.httpRequests.insert(0, entity);

    String body = '${options.method}  ${options.path}';
    Naughty.instance.showNotification(body: body);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    handler.next(response);

    HTTPEntity? entity = _cacheMap[response.requestOptions];
    if (entity == null) return;
    _handleRequest(response.requestOptions, entity);
    _handleResponse(response, entity);
    // 保存请求成功的状态
    entity.status = Status.success;
    bool res = response.statusCode == 200 && response.data['esg'] == 200;
    _handleCompleted(entity, res);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    handler.next(err);

    HTTPEntity? entity = _cacheMap[err.requestOptions];
    if (entity == null) return;
    _handleRequest(err.requestOptions, entity);
    _handleResponse(err.response, entity);
    _handleError(err, entity);
    // 保存请求失败的状态和信息
    entity.status = Status.failed;
    _handleCompleted(entity, false);
  }

  /// 处理请求的信息
  void _handleRequest(RequestOptions options, HTTPEntity entity) {
    entity.duration = '${DateTime.now().millisecondsSinceEpoch - int.parse(entity.duration)} ms';
    entity.method = options.method;
    entity.url = options.uri.toString();
    entity.baseUrl = options.baseUrl;
    entity.path = options.path;
    entity.responseType = options.responseType.toString();
    entity.maxRedirects = options.maxRedirects;
    entity.listFormat = options.listFormat.toString();
    entity.sendTimeout = options.sendTimeout;
    entity.connectTimeout = options.connectTimeout;
    entity.receiveTimeout = options.receiveTimeout;
    entity.followRedirects = options.followRedirects;
    entity.receiveDataWhenStatusError = options.receiveDataWhenStatusError;
    entity.requestExtra = options.extra;
    entity.requestQueryParameters = options.queryParameters;
    entity.requestHeader = options.headers;
    entity.requestBody = options.data;
  }

  /// 处理请求响应的信息
  void _handleResponse(Response? response, HTTPEntity entity) {
    if (response == null) return;
    entity.size = Naughty.instance.formatSize(_getStringLength(response.data.toString()));
    entity.statusCode = response.statusCode ?? -1;
    entity.realUrl = response.realUri.toString();
    entity.isRedirect = response.isRedirect;
    entity.responseExtra = response.extra;
    entity.responseHeader = response.headers.map;
    entity.responseBody = response.data;
  }

  /// 处理请求错误的信息
  void _handleError(DioException err, HTTPEntity entity) {
    entity.realUrl = err.requestOptions.uri.toString();
    entity.responseBody = err.error.toString();
  }

  /// 请求完成
  void _handleCompleted(HTTPEntity entity, bool res) {}

  /// 获取字符串所占用的字节大小
  int _getStringLength(String? str) {
    if (str == null || str.isEmpty) return 0;

    int len = 0;
    utf8.encode(str).forEach((ch) => len += ch > 256 ? 3 : 1);

    return len;
  }
}
