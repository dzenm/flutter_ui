import 'package:dio/dio.dart';
import 'package:flutter_ui/base/naughty/beans/http_bean.dart';
import 'package:flutter_ui/base/naughty/naughty.dart';
import 'package:flutter_ui/base/naughty/utils/str_util.dart';
import 'package:intl/intl.dart';

/// HTTP请求信息拦截
class HttpInterceptor extends Interceptor {
  Map<RequestOptions, HttpBean> map = {};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    HttpBean bean = HttpBean();
    bean.status = Status.running;
    bean.duration = DateTime.now().millisecondsSinceEpoch.toString();
    bean.time = DateFormat("HH:mm:ss SSS").format(DateTime.now());
    map[options] = bean;
    Naughty.getInstance.data.insert(0, bean);

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    HttpBean? bean = map[response.requestOptions];
    if (bean != null) {
      bean.status = Status.success;
      _handle(response, bean);
    }
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    HttpBean? bean = map[err.requestOptions];
    if (bean != null) {
      bean.status = Status.failed;
      _handle(err.response, bean);
    }
    handler.next(err);
  }

  void _handle(Response? response, HttpBean bean) {
    bean.status = Status.success;
    bean.duration = '${DateTime.now().millisecondsSinceEpoch - int.parse(bean.duration)} ms';
    bean.size = StrUtil.formatSize(StrUtil.getStringLength(response?.data.toString()));

    // request
    bean.method = response?.requestOptions.method ?? 'unknown';
    bean.url = response?.requestOptions.uri.toString() ?? 'unknown';
    bean.baseUrl = response?.requestOptions.baseUrl ?? 'unknown';
    bean.path = response?.requestOptions.path;
    bean.requestExtra = response?.requestOptions.extra;
    bean.requestQueryParameters = response?.requestOptions.queryParameters;
    bean.requestHeader = response?.requestOptions.headers;
    bean.requestBody = response?.requestOptions.data;

    // response
    bean.statusCode = response?.statusCode ?? -1;
    bean.realUrl = response?.realUri.toString() ?? 'unknown';
    bean.responseType = response?.requestOptions.responseType.toString() ?? 'unknown';
    bean.maxRedirects = response?.requestOptions.maxRedirects ?? -1;
    bean.listFormat = response?.requestOptions.listFormat.toString() ?? 'unknown';
    bean.sendTimeout = response?.requestOptions.sendTimeout ?? -1;
    bean.connectTimeout = response?.requestOptions.connectTimeout ?? -1;
    bean.receiveTimeout = response?.requestOptions.receiveTimeout ?? -1;
    bean.followRedirects = response?.requestOptions.followRedirects ?? true;
    bean.receiveDataWhenStatusError = response?.requestOptions.receiveDataWhenStatusError ?? true;
    bean.isRedirect = response?.isRedirect ?? false;

    bean.responseExtra = response?.extra;
    Map<String, dynamic> headers = {};
    response?.headers.forEach((key, val) => headers[key] = val);
    bean.responseHeader = headers;
    bean.responseBody = response?.data;
  }
}
