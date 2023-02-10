import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import '../../http/api_services.dart';
import '../log/log.dart';
import '../naughty/http/http_interceptor.dart';
import '../widgets/common_dialog.dart';
import 'log_interceptor.dart';

typedef Success = void Function(dynamic data);

typedef Failed = void Function(HttpError error);

ApiServices apiServices = ApiClient.getInstance._api[ApiClient.getInstance._baseUrls[0]]!;

ApiServices api(int index) => ApiClient.getInstance._api[ApiClient.getInstance._baseUrls[index]]!;

///
/// Created by a0010 on 2022/3/22 09:38
/// HTTP请求
///
class ApiClient {
  static const String _tag = 'ApiClient';
  static const int _connectTimeout = 20000;
  static const int _receiveTimeout = 20000;

  static final ApiClient getInstance = ApiClient._internal();

  Map<String, ApiServices> _api = {};
  List<String> _baseUrls = [
    'https://www.wanandroid.com/',
    'http://api.tianapi.com/',
  ];

  // 构造方法
  ApiClient._internal() {
    _baseUrls.forEach((url) => _createApiServices(baseUrl: url));
  }

  /// 创建ApiServices
  /// baseUrl必须使用 "", 不能使用 ''
  void _createApiServices({required String? baseUrl}) {
    Dio dio = Dio(BaseOptions(
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      // 不使用http状态码判断状态，使用AdapterInterceptor来处理（适用于标准REST风格）
      validateStatus: (status) => true,
      baseUrl: baseUrl!,
      headers: {
        'Accept': 'application/json,*/*',
        'Content-Type': 'application/json',
      },
    ));

    // 不验证https证书
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
      return client;
    };
    // log interceptor
    dio.interceptors.add(LoggerInterceptor(
      isFormat: true,
      logPrint: Log.d,
    ));
    // 通过悬浮窗查看Http请求数据
    dio.interceptors.add(HttpInterceptor());
    // dio.interceptors.add(CookieManager(PersistCookieJar()));
    ApiServices? api = _api[baseUrl];
    if (api == null) {
      _api[baseUrl] = ApiServices(dio, baseUrl: baseUrl);
    }
  }

  // 发起http请求
  Future request(
    Future future, {
    Success? success,
    Failed? failed,
    bool isShowDialog = true,
    bool isShowToast = true,
    CancelFunc? loading,
  }) async {
    CancelFunc? cancel = isShowDialog ? loading ?? loadingDialog() : null;
    HttpError? error;
    try {
      // 没有网络
      await future.then((data) {
        // 根据前后端协议
        if (data.errorCode == 0) {
          if (success != null) {
            success(data.data);
          }
        } else {
          if (data.errorCode == -1001) {
            error = HandleHttpError.handle(code: data.errorCode, msg: data.errorMsg);
          } else if (data.errorCode == -1) {
            error = HandleHttpError.handle(code: data.errorCode, msg: data.errorMsg);
          }
        }
      }).catchError((err) {
        error = HandleHttpError.handle(error: err);
      }, test: (_) => true);
    } catch (err) {
      error = HandleHttpError.handle(error: err);
    }
    _dismissDialog(cancel);
    _handleError(failed, error, isShowToast);
  }

  // 处理错误
  void _handleError(Failed? failed, HttpError? error, bool isShowToast) {
    if (error == null) {
      return;
    }
    if (isShowToast) {
      showToast('${error.msg.isEmpty ? 'No Message' : error.msg} ${error.code}');
    }
    if (failed != null) {
      failed(error);
    }
    Log.d('HTTP请求错误: code=${error.code}, msg=${error.msg}', tag: _tag);
  }

  // 关闭提示框
  void _dismissDialog(CancelFunc? cancel) {
    if (cancel != null) cancel();
  }
}

/// HTTP请求错误信息的处理
class HttpError {
  int code;
  String msg;

  HttpError(this.code, this.msg);
}

/// 异常处理
class HandleHttpError {
  /// code
  static const int successCode = 200;
  static const int successNotContentCode = 204;

  static const int unauthorizedCode = 401;
  static const int forbiddenCode = 403;
  static const int notFoundCode = 404;

  static const int socketErrorCode = 1001;
  static const int httpErrorCode = 1002;
  static const int parseErrorCode = 1003;
  static const int netErrorCode = 1004;

  static const int timeoutErrorCode = 1006;
  static const int sendErrorCode = 1007;
  static const int receiveErrorCode = 1008;
  static const int cancelErrorCode = 1009;

  static const int unknownErrorCode = 1109;

  static const int runtimeErrorCode = 1120;

  /// msg
  static const String successMsg = '';
  static const String successNotContentMsg = '';
  static const String unauthorizedMsg = '未经授权';
  static const String forbiddenMsg = '禁止访问';
  static const String notFoundMsg = '未找到内容';

  static const String socketErrorMsg = '网络异常，请检查你的网络';
  static const String httpErrorMsg = '服务器异常';
  static const String parseErrorMsg = '数据解析错误';
  static const String netErrorMsg = '网络异常，请检查你的网络';

  static const String timeoutErrorMsg = '连接超时';
  static const String sendErrorMsg = '请求超时';
  static const String receiveErrorMsg = '响应超时';
  static const String cancelErrorMsg = '取消请求';

  static const String unknownErrorMsg = '未知异常';

  static const String runtimeErrorMsg = '运行时的错误';

  // 处理异常
  static HttpError handle({error, int code = 0, String msg = ''}) {
    if (code != 0 && msg.isNotEmpty) {
      return HttpError(code, msg);
    } else if (error != null && error is DioError) {
      if (error.type == DioErrorType.other || error.type == DioErrorType.response) {
        dynamic e = error.error;
        if (e is SocketException) {
          return HttpError(socketErrorCode, socketErrorMsg);
        } else if (e is HttpException) {
          return HttpError(httpErrorCode, httpErrorMsg);
        } else if (e is FormatException) {
          return HttpError(parseErrorCode, parseErrorMsg);
        }
        return HttpError(netErrorCode, '$netErrorMsg ${error.toString()}');
      } else if (error.type == DioErrorType.connectTimeout) {
        return HttpError(timeoutErrorCode, timeoutErrorMsg);
      } else if (error.type == DioErrorType.sendTimeout) {
        return HttpError(sendErrorCode, sendErrorMsg);
      } else if (error.type == DioErrorType.receiveTimeout) {
        return HttpError(receiveErrorCode, receiveErrorMsg);
      } else if (error.type == DioErrorType.cancel) {
        return HttpError(cancelErrorCode, cancelErrorMsg);
      }
      return HttpError(unknownErrorCode, '$unknownErrorMsg ${error.toString()}');
    } else if (error != null) {
      return HttpError(runtimeErrorCode, '$runtimeErrorMsg ${error.toString()}');
    } else {
      return HttpError(unknownErrorCode, '$unknownErrorMsg ${error.toString()}');
    }
  }
}
