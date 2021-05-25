import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_ui/http/api_services.dart';
import 'package:flutter_ui/http/exception_handle.dart';
import 'package:flutter_ui/models/data_bean.dart';
import 'package:flutter_ui/widgets/common_dialog.dart';

import 'log_interceptor.dart';

typedef Success = void Function(dynamic data);

typedef Failed = void Function(RequestException e);

ApiClient apiClient = ApiClient.instance;

ApiServices apiServices = ApiClient.instance.apiServices;

/// HTTP请求封装
class ApiClient {
  static const int CONNECT_TIMEOUT = 20000;
  static const int RECEIVE_TIMEOUT = 20000;

  static final ApiClient instance = ApiClient._internal();

  late Dio dio;
  late ApiServices apiServices;

  // 构造方法
  ApiClient._internal() {
    BaseOptions options = BaseOptions(
      connectTimeout: CONNECT_TIMEOUT,
      receiveTimeout: RECEIVE_TIMEOUT,
      validateStatus: (status) {
        // 不使用http状态码判断状态，使用AdapterInterceptor来处理（适用于标准REST风格）
        return true;
      },
      baseUrl: baseUrl,
      headers: httpHeaders(),
    );

    dio = Dio(options);
    // 不验证https证书
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
    };
    // log interceptor
    dio.interceptors.add(LoggerInterceptor());
    apiServices = ApiServices(dio);
  }

  // 请求头
  Map<String, dynamic> httpHeaders() {
    /// 自定义Header
    String token = '';
    return {'Accept': 'application/json,*/*', 'Content-Type': 'application/json', 'token': token};
  }

  // 发起http请求
  void request(
    Future<DataBean> future, {
    Success? success,
    Failed? failed,
    bool isShowDialog = true,
    bool isShowToast = true,
  }) async {
    CancelFunc? cancel = isShowDialog ? loadingDialog() : null;
    try {
      // 没有网络
      await future.then((data) {
        // 根据前后端协议
        if (data.errorCode == 0) {
          if (success != null) success(data.data);
        } else if (data.errorCode == -1001) {
          // 未登录的错误码
          _error(failed, ExceptionHandle.handle(code: ExceptionHandle.un_login), isShowToast);
        } else if (data.errorCode == -1) {
          // 接口错误
          _error(failed, ExceptionHandle.handle(code: ExceptionHandle.api), isShowToast);
        }
        _dismissDialog(cancel);
      }).catchError((err) {
        _dismissDialog(cancel);
        // 异步异常捕获
        _error(failed, ExceptionHandle.handle(error: err), isShowToast);
      }, test: (_) => true);
    } catch (err) {
      _dismissDialog(cancel);
      _error(failed, ExceptionHandle.handle(error: err), isShowToast);
    }
  }

  void _error(Failed? failed, RequestException exception, bool isShowToast) {
    if (isShowToast) showToast(exception.message);
    if (failed != null) failed(exception);
  }

  void _dismissDialog(CancelFunc? cancel) {
    if (cancel != null) cancel();
  }
}

class RequestException {
  int code;
  String message;

  RequestException(this.code, this.message);
}
