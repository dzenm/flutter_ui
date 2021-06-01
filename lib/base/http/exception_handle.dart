import 'dart:io';

import 'package:dio/dio.dart';

import 'api_client.dart';

/// 异常处理
class ExceptionHandle {
  static const int api = 6610;
  static const int un_login = 6611;

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

  static const int timeout_error_code = 1004;
  static const int cancel_error_code = 1005;

  static const int un_login_error_code = 1101;
  static const int api_error_code = 1108;
  static const int unknown_error_code = 1109;

  static const int runtime_error_code = 1120;

  /// message
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
  static const String cancel_error_msg = '取消请求';

  static const String un_login_error_msg = '未登录';
  static const String api_error_msg = '接口错误';
  static const String unknown_error_msg = '未知异常';

  static const String runtime_error_msg = '运行时的错误';

  // 处理异常
  static RequestException handle({error, int code = 0, String message = ''}) {
    if (code == un_login) {
      return RequestException(un_login_error_code, un_login_error_msg);
    } else if (code == api) {
      return RequestException(api_error_code, api_error_msg);
    } else if (error != null && error is DioError) {
      if (error.type == DioErrorType.other || error.type == DioErrorType.response) {
        dynamic e = error.error;
        if (e is SocketException) {
          return RequestException(socket_error_code, socket_error_msg);
        }
        if (e is HttpException) {
          return RequestException(http_error_code, http_error_msg);
        }
        if (e is FormatException) {
          return RequestException(parse_error_code, parse_error_msg);
        }
        return RequestException(net_error_code, net_error_msg);
      } else if (error.type == DioErrorType.connectTimeout || error.type == DioErrorType.sendTimeout || error.type == DioErrorType.receiveTimeout) {
        // 连接超时 || 请求超时 || 响应超时
        return RequestException(timeout_error_code, timeout_error_msg);
      } else if (error.type == DioErrorType.cancel) {
        return RequestException(cancel_error_code, cancel_error_msg);
      } else {
        return RequestException(unknown_error_code, unknown_error_msg);
      }
    } else if (error != null) {
      return RequestException(runtime_error_code, runtime_error_msg);
    } else {
      return RequestException(code, message);
    }
  }
}
