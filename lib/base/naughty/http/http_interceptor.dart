import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../main.dart';
import '../../router/route_manager.dart';
import '../../utils/notification_util.dart';
import '../../utils/str_util.dart';
import '../entities/http_entity.dart';
import '../naughty.dart';
import '../page/http/http_list_page.dart';

/// HTTP请求信息拦截
class HttpInterceptor extends Interceptor {
  Map<RequestOptions, HTTPEntity> map = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    HTTPEntity entity = HTTPEntity();
    entity.status = Status.running;
    entity.duration = DateTime.now().millisecondsSinceEpoch.toString();
    entity.time = DateFormat("HH:mm:ss SSS").format(DateTime.now());
    map[options] = entity;
    Naughty.instance.data.insert(0, entity);

    String body = '${options.method}  ${options.path}';
    NotificationUtil.showNotification(
      body: body,
      onTap: (payload) async => RouteManager.push(Application.context, HTTPListPage()),
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    HTTPEntity? entity = map[response.requestOptions];
    if (entity != null) {
      entity.status = Status.success;
      _handle(response, entity);
    }
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    HTTPEntity? entity = map[err.requestOptions];
    if (entity != null) {
      entity.status = Status.failed;
      _handle(err.response, entity);
    }
    handler.next(err);
  }

  void _handle(Response? response, HTTPEntity entity) {
    entity.status = Status.success;
    entity.duration = '${DateTime.now().millisecondsSinceEpoch - int.parse(entity.duration)} ms';
    entity.size = StrUtil.formatSize(StrUtil.getStringLength(response?.data.toString()));

    // request
    entity.method = response?.requestOptions.method ?? 'unknown';
    entity.url = response?.requestOptions.uri.toString() ?? 'unknown';
    entity.baseUrl = response?.requestOptions.baseUrl ?? 'unknown';
    entity.path = response?.requestOptions.path;
    entity.requestExtra = response?.requestOptions.extra;
    entity.requestQueryParameters = response?.requestOptions.queryParameters;
    entity.requestHeader = response?.requestOptions.headers;
    entity.requestBody = response?.requestOptions.data;

    // response
    entity.statusCode = response?.statusCode ?? -1;
    entity.realUrl = response?.realUri.toString() ?? 'unknown';
    entity.responseType = response?.requestOptions.responseType.toString() ?? 'unknown';
    entity.maxRedirects = response?.requestOptions.maxRedirects ?? -1;
    entity.listFormat = response?.requestOptions.listFormat.toString() ?? 'unknown';
    entity.sendTimeout = response?.requestOptions.sendTimeout;
    entity.connectTimeout = response?.requestOptions.connectTimeout;
    entity.receiveTimeout = response?.requestOptions.receiveTimeout;
    entity.followRedirects = response?.requestOptions.followRedirects ?? true;
    entity.receiveDataWhenStatusError = response?.requestOptions.receiveDataWhenStatusError ?? true;
    entity.isRedirect = response?.isRedirect ?? false;

    entity.responseExtra = response?.extra;
    Map<String, dynamic> headers = {};
    response?.headers.forEach((key, val) => headers[key] = val);
    entity.responseHeader = headers;
    entity.responseBody = response?.data;
  }
}
