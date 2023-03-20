import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';

import '../../http/api_services.dart';
import 'data_entity.dart';
import 'log_interceptor.dart';

typedef Success = void Function(dynamic data);

typedef Failed = void Function(HttpError error);

ApiServices apiServices = HttpsClient.instance._api[HttpsClient.instance._baseUrls[0]]!;

ApiServices api(int index) => HttpsClient.instance._api[HttpsClient.instance._baseUrls[index]]!;

///
/// Created by a0010 on 2022/3/22 09:38
/// HTTP请求
/// 如果需要自定义处理，先初始化
///   HttpsClient.instance.init(
///     logPrint: Log.http,
///     loading: CommonDialog.loading,
///     toast: CommonDialog.showToast,
///     interceptors: [HttpInterceptor(), CookieInterceptor()],
///   );
class HttpsClient {
  static const int _connectTimeout = 20000;
  static const int _receiveTimeout = 20000;

  HttpsClient._internal();

  static final HttpsClient _instance = HttpsClient._internal();

  static HttpsClient get instance => _instance;

  factory HttpsClient() => _instance;

  final Map<String, ApiServices> _api = {};
  final List<String> _baseUrls = [
    'https://www.wanandroid.com/',
    'http://api.tianapi.com/',
    'http://192.168.2.30:8080/api/v1/',
  ];

  /// 日志打印，如果不设置，将不打印日志，如果要设置在使用数据库之前调用 [init]
  Function? _logPrint;

  /// 全局的请求提醒加载框
  Function? _loading;

  /// 全局的错误的toast提醒加载框
  Function? _toast;

  /// 请求拦截器
  final List<Interceptor> _interceptors = [];

  /// 初始化
  void init({
    void Function(dynamic msg, {String tag})? logPrint,
    CancelFunc Function({String? loadingTxt, bool isVertical, bool light})? loading,
    CancelFunc Function(String text, {int seconds})? toast,
    List<Interceptor>? interceptors,
  }) {
    _logPrint = logPrint;
    _toast = toast;
    _loading = loading;

    if (interceptors != null) {
      _interceptors.addAll(interceptors);
    }
    // 日志打印
    _interceptors.add(LoggerInterceptor(formatJson: true, logPrint: (text) => log(text.toString())));
    // 通过悬浮窗查看Http请求数据
    // _interceptors.add(HttpInterceptor());
    // cookie持久化
    // _interceptors.add(CookieInterceptor.instance);

    /// 创建dio
    for (var url in _baseUrls) {
      _createApiServices(baseUrl: url);
    }
  }

  /// 创建ApiServices
  /// baseUrl必须使用 "", 不能使用 ''
  void _createApiServices({required String? baseUrl}) {
    Dio dio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: _connectTimeout),
      receiveTimeout: const Duration(milliseconds: _receiveTimeout),
      // 不使用http状态码判断状态，使用AdapterInterceptor来处理（适用于标准REST风格）
      validateStatus: (status) => true,
      baseUrl: baseUrl!,
      headers: {
        'Accept': 'application/json,*/*',
        'Content-Type': 'application/json',
      },
    ));

    // 不验证https证书
    // (dio.httpClientAdapter as DefaultHttpsClientAdapter).onHttpsClientCreate = (client) {
    //   // config the http client
    //   // client.findProxy = (uri) {
    //   //  //proxy all request to localhost:8888
    //   //  return "192.168.1.1:8888";
    //   //};
    //   client.badCertificateCallback = (X509Certificate cert, String host, int port) {
    //     log("验证https证书: host=$host, port=$port");
    //     return true;
    //   };
    //   // you can also create a new HttpsClient to dio
    //   // return new HttpsClient();
    //   return client;
    // };
    for (var interceptor in _interceptors) {
      dio.interceptors.add(interceptor);
    }
    _api[baseUrl] ??= ApiServices(dio, baseUrl: baseUrl);
  }

  /// 发起http请求
  Future request(
    Future future, {
    Success? success,
    Failed? failed,
    bool isShowDialog = true,
    bool isShowToast = true,
    CancelFunc? loading,
  }) async {
    CancelFunc? cancel;
    if (isShowDialog) {
      if (_loading != null) cancel = _loading!();
      cancel = loading ?? cancel;
    }
    HttpError? error;
    try {
      DataEntity data = await future;
      // 根据前后端协议
      if (data.errorCode == 0 || data.errorCode == 200) {
        if (success != null) success(data.data);
      } else if (data.errorCode == -1) {
        error = _HttpError.handle(code: data.errorCode, msg: data.errorMsg);
      } else if (data.errorCode == -1001) {
        error = _HttpError.handle(code: data.errorCode, msg: data.errorMsg);
      } else {
        error = _HttpError.handle(code: data.errorCode, msg: data.errorMsg);
      }
    } catch (err) {
      error = _HttpError.handle(error: err);
    }
    // 请求结束关闭提示框
    if (cancel != null) cancel();
    // 没有异常，不处理，请求结束
    if (error == null) return;
    // 如果有异常通过toast提醒
    if (isShowToast && _toast != null) _toast!('${error.msg} ${error.code}');
    // 如果需要自定义处理异常，进行自定义异常处理
    if (failed != null) failed(error);
    log('HTTP请求错误: code=${error.code}, msg=${error.msg}');
  }

  void log(String text) => _logPrint == null ? null : _logPrint!(text, tag: 'HttpsClient');
}

/// HTTP请求错误信息的处理
class HttpError {
  int code;
  String msg;

  HttpError(this.code, this.msg);
}

/// 异常处理
class _HttpError {
  /// code
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
  static HttpError handle({error, int? code, String? msg}) {
    code ??= 0;
    msg ??= '';
    if (code != 0 && msg.isNotEmpty) {
      return HttpError(code, msg);
    } else if (error != null && error is DioError) {
      if (error.type == DioErrorType.unknown || error.type == DioErrorType.badResponse) {
        dynamic e = error.error;
        if (e is SocketException) {
          return HttpError(socketErrorCode, socketErrorMsg);
        } else if (e is HttpException) {
          return HttpError(httpErrorCode, httpErrorMsg);
        } else if (e is FormatException) {
          return HttpError(parseErrorCode, parseErrorMsg);
        }
        return HttpError(netErrorCode, '$netErrorMsg ${error.toString()}');
      } else if (error.type == DioErrorType.connectionTimeout) {
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
