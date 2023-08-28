import 'dart:io';

// ignore_for_file: depend_on_referenced_packages
import 'package:dio/dio.dart';
import 'package:dio/src/adapters/io_adapter.dart';
import 'package:flutter/foundation.dart';

import '../../http/api_services.dart';
import 'data_entity.dart';
import 'log_interceptor.dart';

/// 请求成功返回的结果
typedef Success = void Function(dynamic data);

/// 下载文件的进度
typedef Progress = void Function(double percent, int count, int total);

/// 请求完成的标志
typedef Complete = void Function();

/// 请求失败返回的结果
typedef Failed = void Function(HttpError error);

/// 默认[baseUrl]对应的[ApiServices]，用于获取请求
ApiServices apiServices = api();

/// 根据[baseUrl]下标对应的[ApiServices]，用于获取请求
ApiServices api({int index = 0}) => HttpsClient.instance.apiServices(index);

/// HTTP请求错误信息的处理
class HttpError {
  int code;
  String msg;

  HttpError(this.code, this.msg);
}

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
/// 在pubspec.yaml添加下列依赖
/// dependencies:
///  ...
///  # HTTP请求
///  retrofit: 4.0.1
/// dev_dependencies:
///  ...
///  retrofit_generator: 6.0.0+3
//   build_runner: 2.3.2
class HttpsClient {
  static const int _connectTimeout = 20000;
  static const int _receiveTimeout = 20000;

  HttpsClient._internal();

  static final HttpsClient _instance = HttpsClient._internal();

  static HttpsClient get instance => _instance;

  factory HttpsClient() => _instance;

  final Map<String, ApiServices> _apiServices = {};

  ApiServices apiServices(int index) => _apiServices[_baseUrls[index]]!;

  /// 如果存在多个url的情况，在这里添加，默认使用 [apiServices] ，其他使用 [api] 请求接口
  final List<String> _baseUrls = [];

  /// 日志打印，如果不设置，将不打印日志，如果要设置在使用数据库之前调用 [init]
  Function? _logPrint;

  /// 全局的请求提醒加载框
  Function? _loading;

  /// 全局的错误的toast提醒加载框
  Function? _toast;

  /// 请求拦截器
  final List<Interceptor> _interceptors = [];

  /// 初始化
  /// [logPrint] 日志信息处理，可以自定义处理日志
  /// [loading] 全局的加载提示框组件
  /// [toast] 全局的自定义toast提醒
  /// [interceptors] 自定义拦截器
  void init({
    void Function(Object object)? logPrint,
    void Function()? loading,
    Function? toast,
    List<Interceptor>? interceptors,
    List<String>? baseUrls,
  }) {
    _logPrint = logPrint;
    _toast = toast;
    _loading = loading;

    if (interceptors != null) {
      _interceptors.addAll(interceptors);
    }
    // 日志打印
    _interceptors.add(LoggerInterceptor(formatJson: true, logPrint: logPrint));
    // 通过悬浮窗查看Http请求数据
    // _interceptors.add(HttpInterceptor());
    // cookie持久化
    // _interceptors.add(CookieInterceptor.instance);

    if (baseUrls != null) {
      _baseUrls.addAll(baseUrls);
    }
    for (var url in _baseUrls) {
      _apiServices[url] ??= ApiServices(_createDio(baseUrl: url), baseUrl: url);
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
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        HttpClient client = HttpClient();
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
  /// [future] 异步请求的信息
  /// [success] 请求成功的结果，如果[isCustomResult]为true，返回的data是未经处理的response body，为false，返回的是[DataEntity.data]
  /// [complete] 请求完成的结果，不返回任何结果，不管是成功还是失败都会进入[complete]
  /// [failed] 请求失败的结果，[HttpError] 是失败的信息
  /// [isShowDialog] 是否显示加载的dialog，可以在[init]自定义全局的加载弹窗提示，[loading]为局部的加载弹窗提示
  /// [isShowToast] 是否显示错误的toast提醒
  /// [isCustomResult] 是否自定义处理response body，@see [success]
  /// [loading] 自定义加载弹窗提示，@see [isShowDialog]
  Future<void> request(
    Future<DataEntity> future, {
    Success? success,
    Failed? failed,
    Complete? complete,
    bool isShowDialog = true,
    bool isShowToast = true,
    bool isCustomResult = false,
    void Function()? loading,
  }) async {
    Function? cancel;
    if (isShowDialog) {
      // 优先使用局部的加载提示框
      Function? loadingFunc = loading ?? _loading;
      if (loadingFunc != null) cancel = loadingFunc();
    }
    HttpError? error;
    try {
      await future.then((DataEntity data) {
        if (isCustomResult) {
          if (success != null) success(data);
          return;
        }
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
    if (complete != null) complete();
    // 请求结束关闭提示框
    if (isShowDialog && cancel != null) cancel();
    // 没有异常，不处理，请求结束
    if (error == null) return;

    // 如果有异常通过toast提醒
    if (isShowToast && _toast != null) _toast!('${error!.msg}，code=${error!.code}');
    // 如果需要自定义处理异常，进行自定义异常处理
    if (failed != null) failed(error!);
    log('HTTP请求错误: code=${error!.code}, msg=${error!.msg}');
  }

  /// 下载文件
  /// [url] 下载文件的url
  /// [savePath] 保存文件的路径
  /// [cancel] 取消下载请求的token
  /// [success] 下载成功返回的结果
  /// [progress] 下载的进度
  /// [failed] 下载失败返回的结果
  Future<void> download(
    String url,
    dynamic savePath, {
    CancelToken? cancel,
    Success? success,
    Progress? progress,
    Failed? failed,
  }) async {
    HttpError? error;
    try {
      Response response = await Dio().download(
        url,
        savePath,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
        cancelToken: cancel,
        onReceiveProgress: (int count, int total) {
          if (progress == null) return;
          // 获取下载进度
          double progressPercent = double.parse((count / total).toStringAsFixed(2));
          progress(progressPercent, count, total);
        },
      );
      if (response.statusCode == 200 || response.statusCode == 206) {
        // 下载成功的返回结果
        if (success != null) {
          success(response.data);
        }
      } else {
        // 下载请求失败的错误信息
        error = HttpError(response.statusCode ?? 1000, response.statusMessage ?? '');
      }
    } on DioException catch (e) {
      // 下载失败的错误信息
      error = HttpError(1000, e.message ?? '');
    }
    // 下载结果
    if (error == null) return;
    if (failed != null) failed(error);
  }

  Future<void> upload() async {}

  void log(dynamic text) => _logPrint == null ? null : _logPrint!(text, tag: 'HttpsClient');
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
    } else if (error != null && error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout) {
        return HttpError(timeoutCode, timeoutMsg);
      } else if (error.type == DioExceptionType.sendTimeout) {
        return HttpError(sendCode, sendMsg);
      } else if (error.type == DioExceptionType.receiveTimeout) {
        return HttpError(receiveCode, receiveMsg);
      } else if (error.type == DioExceptionType.badCertificate) {
        return HttpError(badCertificateCode, badCertificateMsg);
      } else if (error.type == DioExceptionType.badResponse) {
        return HttpError(error.response?.statusCode ?? 0, error.response?.statusMessage ?? '');
      } else if (error.type == DioExceptionType.cancel) {
        return HttpError(cancelCode, cancelMsg);
      } else if (error.type == DioExceptionType.connectionError) {
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
