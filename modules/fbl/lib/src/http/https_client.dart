import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import 'data_entity.dart';
import 'log_interceptor.dart';

/// 请求成功返回的结果，使用Future<void> 作为返回值，是为了在有些情况保证执行 [Success]
/// 之后能够拿到通过 [HttpsClient.request] 请求返回的 Future<dynamic>
typedef Success<T> = Future<void> Function(T data);

/// 下载/上传文件的进度
typedef Progress = void Function(double percent, int count, int total);

/// 请求失败返回的结果，使用Future<void> 作为返回值，是为了在有些情况保证执行 [Failed]
/// 之后能够拿到通过 [HttpsClient.request] 请求返回的 Future<dynamic>
typedef Failed = Future<void> Function(HttpError error);

/// 创建ApiServices，@see [HttpsClient.init]
typedef ApiCreator = void Function(Dio dio, String baseUrl);

/// 请求响应后的拦截器, true表示进行拦截，false表示不拦截
typedef ResponseInterceptor = bool Function(DataEntity data);

/// HTTP请求错误信息的处理
class HttpError {
  int code;
  String msg;
  String error;

  HttpError(this.code, this.msg, this.error);
}

///
/// Created by a0010 on 2022/3/22 09:38
/// HTTP请求
/// 如果需要自定义处理，先初始化
///   HttpsClient().init(
///     logPrint: Log.h,
///     loading: CommonDialog.loading,
///     toast: CommonDialog.showToast,
///     interceptors: [HttpInterceptor(), CookieInterceptor()],
///   );
final class HttpsClient {
  static const int _connectTimeout = 20000;
  static const int _receiveTimeout = 20000;

  factory HttpsClient() => _instance;
  static final HttpsClient _instance = HttpsClient._internal();

  HttpsClient._internal();

  /// 如果存在多个url的情况，在这里添加，默认使用 [apiServices] ，其他使用 [api] 请求接口
  final List<String> _baseUrls = [];

  /// 全局的请求提醒加载框
  void Function()? _loading;

  /// 全局的错误的toast提醒加载框
  Function? _toast;

  /// 请求响应拦截器
  ResponseInterceptor? _interceptor;

  /// 请求拦截器
  final List<Interceptor> _interceptors = [];

  /// 初始化
  /// [logPrint] 日志信息处理，可以自定义处理日志
  /// [addHeaders] 添加请求头
  /// [loading] 全局的加载提示框组件
  /// [toast] 全局的自定义toast提醒
  /// [interceptors] 自定义拦截器
  /// [creator] 创建ApiServices
  void init({
    void Function(Object object, {String tag})? logPrint,
    Map<String, dynamic> Function()? addHeaders,
    void Function()? loading,
    Function? toast,
    List<Interceptor>? interceptors,
    ResponseInterceptor? interceptor,
    List<String>? baseUrls,
    ApiCreator? creator,
  }) {
    _toast = toast;
    _loading = loading;

    if (interceptors != null) {
      _interceptors.addAll(interceptors);
    }
    _interceptor = interceptor;
    // 日志打印
    _interceptors.add(LoggerInterceptor(
      config: LogInterceptorConfig(
        isFormatJson: true,
        logPrint: logPrint,
        addHeaders: addHeaders,
      ),
    ));
    // 通过悬浮窗查看Http请求数据
    // _interceptors.add(HttpInterceptor());
    // cookie持久化
    // _interceptors.add(CookieInterceptor.instance);

    if (baseUrls != null) {
      _baseUrls.addAll(baseUrls);
    }
    for (var url in _baseUrls) {
      if (creator == null) continue;
      creator(_createDio(baseUrl: url), url);
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
        HttpHeaders.acceptHeader: 'text/plain,text/html,text/json,text/javascript,'
            'image/jpeg,image/png,multipart/form-data,'
            'application/json,application/octet-stream,*/*',
        HttpHeaders.contentTypeHeader: Headers.jsonContentType,
        // Web端报错处理
        HttpHeaders.accessControlAllowOriginHeader: '*', // Required for CORS support to work
        HttpHeaders.accessControlAllowCredentialsHeader: 'true', // Required for cookies, authorization headers with HTTPS
        HttpHeaders.accessControlAllowHeadersHeader: 'Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale',
        HttpHeaders.accessControlAllowMethodsHeader: 'GET,POST,PUT,OPTIONS,DELETE',
      },
    ));

    if (!kIsWeb) {
      // 不验证https证书
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        HttpClient client = HttpClient();
        // 配制网络代理抓包
        // config the http client
        // client.findProxy = (uri) {
        //  //proxy all request to localhost:8888
        //  return "192.168.1.1:8888";
        //};
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          // log("验证https证书: host=$host, port=$port");
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
  /// [failed] 请求失败的结果，[HttpError] 是失败的信息
  /// [isShowDialog] 是否显示加载的dialog，可以在[init]自定义全局的加载弹窗提示，[loading]为局部的加载弹窗提示
  /// [isShowToast] 是否显示错误的toast提醒
  /// [loading] 自定义加载弹窗提示，@see [isShowDialog]
  Future<T?> request<T>(
    Future<DataEntity<T>> future, {
    Success<T?>? success,
    Failed? failed,
    bool isShowDialog = true,
    bool isShowToast = true,
    void Function()? loading,
    ResponseInterceptor? interceptor,
  }) async {
    Function? cancelLoading;
    if (isShowDialog) {
      // 如果需要显示加载提示框，优先使用局部定义的加载提示框
      Function? showLoading = loading ?? _loading;
      cancelLoading = showLoading?.call();
    }

    void cancel() => cancelLoading?.call();

    HttpError? error;
    T? data;
    try {
      // 执行请求
      DataEntity<T?> result = await future;
      // 判断是否拦截
      ResponseInterceptor? responseInterceptor = interceptor;
      // 局部拦截
      if (responseInterceptor != null && responseInterceptor(result)) {
        cancel();
        return null;
      }
      // 全局拦截
      responseInterceptor = _interceptor;
      if (responseInterceptor != null && responseInterceptor(result)) {
        cancel();
        return null;
      }
      // 根据前后端协议
      if (result.isSuccessful) {
        data = result.data;
      } else {
        error = parse(code: result.errorCode, msg: result.errorMsg);
      }
    } catch (err) {
      error = parse(error: err);
    }
    // 请求结束关闭提示框
    cancel();
    if (error == null) {
      // 请求成功
      await success?.call(data);
    } else {
      // 请求失败，需要自定义处理异常，处理异常
      await failed?.call(error);
      // 如果有异常通过toast提醒
      if (isShowToast) _toast?.call(error.msg);
    }
    return data;
  }

  /// 下载文件
  /// [url] 下载文件的url
  /// [cancelToken] 取消下载请求的token
  /// [success] 下载成功返回的结果
  /// [progress] 下载的进度
  /// [failed] 下载失败返回的结果
  /// [canCancel] 是否可以取消下载
  Future<Uint8List?> download(
    String url, {
    CancelToken? cancelToken,
    Success? success,
    Progress? progress,
    Failed? failed,
    bool canCancel = true,
  }) async {
    HttpError? error;
    try {
      Dio dio = _createDio(baseUrl: _baseUrls.first);
      Response response = await dio.get<Uint8List>(
        url,
        onReceiveProgress: (int count, int total) {
          // 未实现/禁止取消/通过token取消下载等情况不能再进行处理
          if (progress == null || (canCancel && (cancelToken?.isCancelled ?? false))) return;
          if (total == -1) {
            // 无法获取文件大小
            _HttpException ex = _HttpException.fileNotExist;
            error = HttpError(ex.code, ex.msg, ex.msg);
          } else {
            // 获取下载进度
            double progressPercent = double.parse((count / total).toStringAsFixed(2));
            progress(progressPercent, count, total);
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
      );
      Uint8List? data = response.data;
      if (response.statusCode == 200 || response.statusCode == 206) {
        // 下载成功的返回结果
        if (success != null) {
          await success(data);
        }
        return data;
      } else {
        // 下载请求失败的错误信息
        error = HttpError(response.statusCode ?? 1000, response.statusMessage ?? '', error.toString());
      }
    } on DioException catch (e) {
      // 下载失败的错误信息
      error = HttpError(1000, e.message ?? '', error.toString());
    }
    // 下载结果
    if (error == null) return null;
    if (failed != null) await failed(error!);
    return null;
  }

  /// 上传文件
  /// [cancelToken] 取消上传请求的token
  /// [success] 上传成功返回的结果
  /// [onSendProgress] 上传的进度
  /// [failed] 上传失败返回的结果
  Future<dynamic> upload(
    String url,
    dynamic data, {
    CancelToken? cancelToken,
    Success? success,
    Progress? onSendProgress,
    Progress? onReceiveProgress,
    Failed? failed,
    bool canCancel = true,
  }) async {
    HttpError? error;
    try {
      Dio dio = _createDio(baseUrl: _baseUrls.first);
      final Response response = await dio.request(
        url,
        data: data,
        cancelToken: canCancel ? cancelToken : null,
        options: Options(
          method: 'POST',
          // headers: {r'authorization': SpUtil.getToken()},
          contentType: 'multipart/form-data',
        ),
        onSendProgress: (int count, int total) {
          // 未实现/禁止取消/通过token取消下载等情况不能再进行处理
          if (onSendProgress == null || (canCancel && (cancelToken?.isCancelled ?? false))) return;
          if (total == -1) {
            // 无法获取文件大小
            _HttpException ex = _HttpException.fileNotExist;
            error = HttpError(ex.code, ex.msg, ex.msg);
          } else {
            // 获取下载进度
            double progressPercent = double.parse((count / total).toStringAsFixed(2));
            onSendProgress(progressPercent, count, total);
          }
        },
        onReceiveProgress: (int count, int total) {
          // 未实现/禁止取消/通过token取消下载等情况不能再进行处理
          if (onReceiveProgress == null || (canCancel && (cancelToken?.isCancelled ?? false))) return;

          // 获取接收进度
          double progressPercent = double.parse((count / total).toStringAsFixed(2));
          onReceiveProgress(progressPercent, count, total);
        },
      );
      if (response.statusCode == 200) {
        final value = DataEntity<dynamic>.fromJson(response.data!);
        // 下载成功的返回结果
        if (success != null) {
          await success(value.data);
        }
        return value.data;
      } else {
        // 下载请求失败的错误信息
        error = HttpError(response.statusCode ?? 1000, response.statusMessage ?? '', error.toString());
      }
    } on DioException catch (e) {
      // 下载失败的错误信息
      error = HttpError(1000, e.message ?? '', error.toString());
    }
    // 下载结果
    if (error == null) return null;
    if (failed != null) await failed(error!);
    return null;
  }

  /// 处理异常
  HttpError parse({dynamic error, int? code = 0, String? msg = ''}) {
    if ((code ?? 0) > 0 || (msg ?? '').isNotEmpty) {
      return HttpError(code ?? 0, msg ?? '未知状态码错误', 'HTTP状态码错误');
    }
    _HttpException exception = _HttpException.error;
    if (error != null) {
      if (error is HttpException) {
        exception = _HttpException.http;
      } else if (error is FormatException) {
        exception = _HttpException.format;
      } else if (error is SocketException) {
        exception = _HttpException.socket;
      } else if (error is DioException) {
        switch (error.type) {
          case DioExceptionType.connectionTimeout:
            exception = _HttpException.connect;
            break;
          case DioExceptionType.sendTimeout:
            exception = _HttpException.send;
            break;
          case DioExceptionType.receiveTimeout:
            exception = _HttpException.receive;
            break;
          case DioExceptionType.badCertificate:
            exception = _HttpException.badCertificate;
            break;
          case DioExceptionType.badResponse:
            exception = _HttpException.badResponse;
            break;
          case DioExceptionType.cancel:
            exception = _HttpException.cancel;
            break;
          case DioExceptionType.connectionError:
            exception = _HttpException.connection;
            break;
          case DioExceptionType.unknown:
            exception = _HttpException.unknown;
            break;
        }
      }
    }
    return HttpError(exception.code, exception.msg, error.toString());
  }
}

enum _HttpException {
  http(1001, '服务器异常'),
  socket(1002, 'Socket异常'),
  format(1003, '数据解析异常'),
  error(1004, '连接异常'),
  fileNotExist(1004, '无法获取文件'),
  connect(1006, '连接超时'),
  send(1007, '请求超时'),
  receive(1008, '响应超时'),
  badCertificate(1009, '证书错误'),
  badResponse(10010, '响应错误'),
  cancel(1011, '请求被取消'),
  connection(1012, '连接失败'),
  unknown(1109, '未知异常');

  final int code;
  final String msg;

  const _HttpException(this.code, this.msg);
}
