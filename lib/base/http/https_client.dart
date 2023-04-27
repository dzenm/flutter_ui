import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:dio/dio.dart';
import 'package:dio/src/adapters/io_adapter.dart';
import 'package:flutter/foundation.dart';

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
/// TODO api_services
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
    CancelFunc Function()? loading,
    Function? toast,
    List<Interceptor>? interceptors,
  }) {
    _logPrint = logPrint;
    _toast = toast;
    _loading = loading;

    if (interceptors != null) {
      _interceptors.addAll(interceptors);
    }
    // 日志打印
    _interceptors.add(LoggerInterceptor(formatJson: true, logPrint: log));
    // 通过悬浮窗查看Http请求数据
    // _interceptors.add(HttpInterceptor());
    // cookie持久化
    // _interceptors.add(CookieInterceptor.instance);

    for (var url in _baseUrls) {
      _api[url] ??= ApiServices(_createDio(baseUrl: url), baseUrl: url);
    }
  }

  /// 创建ApiServices
  /// baseUrl必须使用 "", 不能使用 ''
  Dio _createDio({required String? baseUrl}) {
    Dio dio = Dio(BaseOptions(
      connectTimeout: const Duration(milliseconds: _connectTimeout),
      receiveTimeout: const Duration(milliseconds: _receiveTimeout),
      // 不使用http状态码判断状态，使用AdapterInterceptor来处理（适用于标准REST风格）
      validateStatus: (status) => true,
      baseUrl: baseUrl!,
      headers: {
        'Accept': 'application/json,*/*',
        'Content-Type': 'application/json',
        /// Web端报错处理
        "Access-Control-Allow-Origin": "*", // Required for CORS support to work
        "Access-Control-Allow-Credentials": 'true', // Required for cookies, authorization headers with HTTPS
        "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
        "Access-Control-Allow-Methods": "GET, POST, PUT, OPTIONS, DELETE",
      },
    ));

    if (!kIsWeb) {
      // 不验证https证书
      (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
        // config the http client
        // client.findProxy = (uri) {
        //  //proxy all request to localhost:8888
        //  return "192.168.1.1:8888";
        //};
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          log("验证https证书: host=$host, port=$port");
          return true;
        };
        // you can also create a new HttpsClient to dio
        // return new HttpsClient();
        return client;
      };
    }
    for (var interceptor in _interceptors) {
      dio.interceptors.add(interceptor);
    }
    return dio;
  }

  /// 发起http请求
  Future request(
    Future<DataEntity> future, {
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
      await future.then((DataEntity data) {
        // 根据前后端协议
        if (data.errorCode == 0 || data.errorCode == 200) {
          if (success != null) success(data.data);
        } else if (data.errorCode == -1) {
          error = _HandlerError.parse(code: data.errorCode, msg: data.errorMsg);
        } else if (data.errorCode == -1001) {
          error = _HandlerError.parse(code: data.errorCode, msg: data.errorMsg);
        } else {
          error = _HandlerError.parse(code: data.errorCode, msg: data.errorMsg);
        }
      }).catchError((err) {
        error = _HandlerError.parse(error: err);
      });
    } catch (err) {
      error = _HandlerError.parse(error: err);
    }
    // 请求结束关闭提示框
    if (cancel != null) cancel();
    // 没有异常，不处理，请求结束
    if (error == null) return;
    // 如果有异常通过toast提醒
    if (isShowToast && _toast != null) _toast!('${error!.msg} ${error!.code}');
    // 如果需要自定义处理异常，进行自定义异常处理
    if (failed != null) failed(error!);
    log('HTTP请求错误: code=${error!.code}, msg=${error!.msg}');
  }

  void log(dynamic text) => _logPrint == null ? null : _logPrint!(text, tag: 'HttpsClient');
}

/// HTTP请求错误信息的处理
class HttpError {
  int code;
  String msg;

  HttpError(this.code, this.msg);
}

/// 异常处理
class _HandlerError {
  /// code
  static const int socketCode = 1001;
  static const int httpCode = 1002;
  static const int connectionCode = 1003;
  static const int formatCode = 1004;

  static const int timeoutCode = 1006;
  static const int sendCode = 1007;
  static const int receiveCode = 1008;
  static const int badCertificateCode = 1009;
  static const int cancelCode = 1010;

  static const int unknownCode = 1109;

  static const int runtimeCode = 1120;

  /// msg
  static const String socketMsg = '网络异常，请检查你的网络';
  static const String httpMsg = '服务器异常';
  static const String connectionMsg = '连接异常';
  static const String formatMsg = '数据解析异常';

  static const String timeoutMsg = '连接超时';
  static const String sendMsg = '请求超时';
  static const String receiveMsg = '响应超时';
  static const String badCertificateMsg = '无效的证书';
  static const String cancelMsg = '请求被取消';

  static const String unknownMsg = '未知异常';

  static const String runtimeMsg = '运行时的异常';

  // 处理异常
  static HttpError parse({error, int? code, String? msg}) {
    code ??= 0;
    msg ??= '';
    if (code > 0 && msg.isNotEmpty) {
      return HttpError(code, msg);
    } else if (error != null && error is DioError) {
      if (error.type == DioErrorType.connectionTimeout) {
        return HttpError(timeoutCode, timeoutMsg);
      } else if (error.type == DioErrorType.sendTimeout) {
        return HttpError(sendCode, sendMsg);
      } else if (error.type == DioErrorType.receiveTimeout) {
        return HttpError(receiveCode, receiveMsg);
      } else if (error.type == DioErrorType.badCertificate) {
        return HttpError(badCertificateCode, badCertificateMsg);
      } else if (error.type == DioErrorType.badResponse) {
        return HttpError(error.response?.statusCode ?? 0, error.response?.statusMessage ?? '');
      } else if (error.type == DioErrorType.cancel) {
        return HttpError(cancelCode, cancelMsg);
      } else if (error.type == DioErrorType.connectionError) {
        if (error.error is SocketException) {
          return HttpError(socketCode, socketMsg);
        } else if (error.error is HttpException) {
          return HttpError(httpCode, httpMsg);
        }
        return HttpError(connectionCode, '$connectionMsg ${error.toString()}');
      } else if (error.error is FormatException) {
        return HttpError(formatCode, formatMsg);
      }
      return HttpError(unknownCode, '$unknownMsg ${error.toString()}');
    } else if (error != null) {
      return HttpError(runtimeCode, '$runtimeMsg ${error.toString()}');
    } else {
      return HttpError(unknownCode, '$unknownMsg ${error.toString()}');
    }
  }
}