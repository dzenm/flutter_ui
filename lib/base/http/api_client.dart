import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_ui/base/entities/data_entity.dart';
import 'package:flutter_ui/base/naughty/http/http_interceptor.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/http/api_services.dart';

import '../log/log.dart';
import 'log_interceptor.dart';

typedef Success = void Function(dynamic? data);

typedef Failed = void Function(HttpError e);

ApiServices apiServices = ApiClient.getInstance._apiServices;

/// HTTP请求错误信息的处理
class HttpError {
  int code;
  String msg;

  HttpError(this.code, this.msg);
}

/// HTTP请求
class ApiClient {
  static const int _CONNECT_TIMEOUT = 20000;
  static const int _RECEIVE_TIMEOUT = 20000;

  static final ApiClient getInstance = ApiClient._internal();

  late ApiServices _apiServices;

  // 构造方法
  ApiClient._internal() {
    _createDio();
  }

  /// 创建dio
  /// baseUrl必须使用 "", 不能使用 ''
  void _createDio({String? baseUrl, String? token}) {
    baseUrl = baseUrl ?? "https://www.wanandroid.com/";
    token = token ?? '';

    Dio dio = Dio(BaseOptions(
      connectTimeout: _CONNECT_TIMEOUT,
      receiveTimeout: _RECEIVE_TIMEOUT,
      // 不使用http状态码判断状态，使用AdapterInterceptor来处理（适用于标准REST风格）
      validateStatus: (status) => true,
      baseUrl: baseUrl,
      headers: {
        'Accept': 'application/json,*/*',
        'Content-Type': 'application/json',
        'token': token,
      },
    ));

    // 不验证https证书
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
    };
    // log interceptor
    dio.interceptors.add(LoggerInterceptor());
    // 通过悬浮窗查看Http请求数据
    dio.interceptors.add(HttpInterceptor());
    // dio.interceptors.add(CookieManager(PersistCookieJar()));
    _apiServices = ApiServices(dio, baseUrl: baseUrl);
  }

  // 发起http请求
  Future request(
    Future future, {
    Success? success,
    Failed? failed,
    bool isShowDialog = true,
    bool isShowToast = true,
  }) async {
    CancelFunc? cancel = isShowDialog ? loadingDialog() : null;
    try {
      // 没有网络
      await future.then((data) {
        _dismissDialog(cancel);
        // 根据前后端协议
        if (data.errorCode == 0) {
          if (success != null) {
            success(data.data);
          }
        } else if (data.errorCode == -1001) {
          Log.d('HTTP请求/未登录: ${data.errorCode}, ${data.errorMsg}');
          _handleError(failed, HandleHttpError.handle(code: data.errorCode, msg: data.errorMsg), isShowToast);
        } else if (data.errorCode == -1) {
          Log.d('HTTP请求/接口错误: ${data.errorCode}, ${data.errorMsg}');
          _handleError(failed, HandleHttpError.handle(code: data.errorCode, msg: data.errorMsg), isShowToast);
        }
      }).catchError((err) {
        _dismissDialog(cancel);
        Log.d('HTTP请求/异步时捕获的异常信息: ${err.toString()}');
        _handleError(failed, HandleHttpError.handle(error: err), isShowToast);
      }, test: (_) => true);
    } catch (err) {
      _dismissDialog(cancel);
      Log.d('HTTP请求/捕获的异常信息: ${err.toString()}');
      _handleError(failed, HandleHttpError.handle(error: err), isShowToast);
    }
  }

  // 处理错误
  void _handleError(Failed? failed, HttpError error, bool isShowToast) {
    if (isShowToast) {
      showToast('${error.msg.isEmpty ? 'No Message' : error.msg} ${error.code}');
    }
    if (failed != null) {
      failed(error);
    }
  }

  // 关闭提示框
  void _dismissDialog(CancelFunc? cancel) {
    if (cancel != null) cancel();
  }
}

/// 异常处理
class HandleHttpError {
  /// code
  static const int success_code = 200;
  static const int success_not_content_code = 204;

  static const int unauthorized_code = 401;
  static const int forbidden_code = 403;
  static const int not_found_code = 404;

  static const int socket_error_code = 1001;
  static const int http_error_code = 1002;
  static const int parse_error_code = 1003;
  static const int net_error_code = 1004;

  static const int timeout_error_code = 1006;
  static const int send_error_code = 1007;
  static const int receive_error_code = 1008;
  static const int cancel_error_code = 1009;

  static const int unknown_error_code = 1109;

  static const int runtime_error_code = 1120;

  /// msg
  static const String success_msg = '';
  static const String success_not_content_msg = '';
  static const String unauthorized_msg = '未经授权';
  static const String forbidden_msg = '禁止访问';
  static const String not_found_msg = '未找到内容';

  static const String socket_error_msg = '网络异常，请检查你的网络';
  static const String http_error_msg = '服务器异常';
  static const String parse_error_msg = '数据解析错误';
  static const String net_error_msg = '网络异常，请检查你的网络';

  static const String timeout_error_msg = '连接超时';
  static const String send_error_msg = '请求超时';
  static const String receive_error_msg = '响应超时';
  static const String cancel_error_msg = '取消请求';

  static const String unknown_error_msg = '未知异常';

  static const String runtime_error_msg = '运行时的错误';

  // 处理异常
  static HttpError handle({error, int code = 0, String msg = ''}) {
    if (code != 0 && msg.isNotEmpty) {
      return HttpError(code, msg);
    } else if (error != null && error is DioError) {
      if (error.type == DioErrorType.other || error.type == DioErrorType.response) {
        dynamic e = error.error;
        if (e is SocketException) {
          return HttpError(socket_error_code, socket_error_msg);
        }
        if (e is HttpException) {
          return HttpError(http_error_code, http_error_msg);
        }
        if (e is FormatException) {
          return HttpError(parse_error_code, parse_error_msg);
        }
        return HttpError(net_error_code, net_error_msg);
      } else if (error.type == DioErrorType.connectTimeout) {
        return HttpError(timeout_error_code, timeout_error_msg);
      } else if (error.type == DioErrorType.sendTimeout) {
        return HttpError(send_error_code, send_error_msg);
      } else if (error.type == DioErrorType.receiveTimeout) {
        return HttpError(receive_error_code, receive_error_msg);
      } else if (error.type == DioErrorType.cancel) {
        return HttpError(cancel_error_code, cancel_error_msg);
      } else {
        return HttpError(unknown_error_code, unknown_error_msg);
      }
    } else if (error != null) {
      return HttpError(runtime_error_code, runtime_error_msg);
    } else {
      return HttpError(unknown_error_code, unknown_error_msg);
    }
  }
}
