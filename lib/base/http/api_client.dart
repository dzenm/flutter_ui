import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_ui/base/http/exception_handle.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/http/api_services.dart';

import 'log.dart';
import 'log_interceptor.dart';

typedef Success = void Function(dynamic data);

typedef Failed = void Function(RequestException e);

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
    _createDio();
  }

  void _createDio() {
    dio = Dio(BaseOptions(
      connectTimeout: CONNECT_TIMEOUT,
      receiveTimeout: RECEIVE_TIMEOUT,
      validateStatus: (status) {
        // 不使用http状态码判断状态，使用AdapterInterceptor来处理（适用于标准REST风格）
        return true;
      },
      baseUrl: _baseUrl(),
      headers: httpHeaders(),
    ));
    // 不验证https证书
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
    };
    // log interceptor
    dio.interceptors.add(LoggerInterceptor());
    apiServices = ApiServices(dio, baseUrl: _baseUrl());
  }

  String _baseUrl() {
    // baseUrl必须使用 "", 不能使用 ''
    const String baseUrl = "https://www.wanandroid.com/";
    return baseUrl;
  }

  // 请求头
  Map<String, dynamic> httpHeaders() {
    /// 自定义Header
    String token = '';
    return {'Accept': 'application/json,*/*', 'Content-Type': 'application/json', 'token': token};
  }

  // 发起http请求
  void request(Future future, {Success? success, Failed? failed, bool isShowDialog = true, bool isShowToast = true}) async {
    CancelFunc? cancel = isShowDialog ? loadingDialog() : null;
    try {
      // 没有网络
      await future.then((data) {
        _dismissDialog(cancel);
        // 根据前后端协议
        if (data.errorCode == 0) {
          if (success != null) success(data.data);
        } else if (data.errorCode == -1001) {
          Log.d('HTTP请求-未登录: ${data.errorCode}, ${data.errorMsg}');
          // 未登录
          _error(failed, ExceptionHandle.handle(code: ExceptionHandle.un_login), isShowToast);
        } else if (data.errorCode == -1) {
          Log.d('HTTP请求-接口错误: ${data.errorCode}, ${data.errorMsg}');
          // 接口错误
          _error(failed, ExceptionHandle.handle(code: ExceptionHandle.api), isShowToast);
        }
      }).catchError((err) {
        Log.d('HTTP请求-异步时捕获的异常信息: ${err.toString()}');
        _dismissDialog(cancel);
        // 异步时捕获的异常
        _error(failed, ExceptionHandle.handle(error: err), isShowToast);
      }, test: (_) => true);
    } catch (err) {
      Log.d('HTTP请求-捕获的异常信息: ${err.toString()}');
      _dismissDialog(cancel);
      // 捕获的异常信息
      _error(failed, ExceptionHandle.handle(error: err), isShowToast);
    }
  }

  void _error(Failed? failed, RequestException exception, bool isShowToast) {
    if (isShowToast) showToast('${exception.message.isEmpty ? 'no message' : exception.message}: ${exception.code}');
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
