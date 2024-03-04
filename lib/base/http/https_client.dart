import 'dart:io';

// ignore_for_file: depend_on_referenced_packages
import 'package:dio/dio.dart';
import 'package:dio/src/adapters/io_adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

import '../../http/api_services.dart';
import 'data_entity.dart';
import 'log_interceptor.dart';

/// 请求成功返回的结果
typedef Success = void Function(dynamic data);

/// 下载/上传文件的进度
typedef Progress = void Function(double percent, int count, int total);

/// 请求完成的标志
typedef Complete = void Function();

/// 请求失败返回的结果
typedef Failed = void Function(HttpError error);

/// 默认[HttpsClient._baseUrls]对应的[ApiServices]，用于获取请求
ApiServices apiServices = api();

/// 根据[HttpsClient._baseUrls]下标对应的[ApiServices]，用于获取请求
ApiServices api({int index = 0}) => HttpsClient().apiServices(index);

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
    void Function(Object object, {String tag})? logPrint,
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
  /// [complete] 请求完成的结果，不返回任何结果，不管是成功还是失败都会进入[complete]
  /// [failed] 请求失败的结果，[HttpError] 是失败的信息
  /// [isShowDialog] 是否显示加载的dialog，可以在[init]自定义全局的加载弹窗提示，[loading]为局部的加载弹窗提示
  /// [isShowToast] 是否显示错误的toast提醒
  /// [isCustomResult] 是否自定义处理response body，@see [success]
  /// [loading] 自定义加载弹窗提示，@see [isShowDialog]
  Future<DataEntity?> request(
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
    HttpError? error;
    DataEntity? result;
    if (isShowDialog) {
      // 优先使用局部的加载提示框
      Function? loadingFunc = loading ?? _loading;
      if (loadingFunc != null) cancel = loadingFunc();
    }
    try {
      var data = await future;
      if (isCustomResult) {
        if (success != null) success(data);
        result = data;
      } else {
        // 根据前后端协议
        if (data.errorCode == 0 || data.errorCode == 200) {
          if (success != null) success(data.data);
          result = data;
        } else {
          error = parse(code: data.errorCode, msg: data.errorMsg);
        }
      }
    } catch (err) {
      error = parse(error: err);
    }
    if (complete != null) complete();
    // 请求结束关闭提示框
    if (cancel != null) cancel();
    // 没有异常，不处理，请求结束
    if (error == null) return result;

    // 如果有异常通过toast提醒
    if (isShowToast && _toast != null) _toast!('请求错误：${error.msg}');
    // 如果需要自定义处理异常，进行自定义异常处理
    if (failed != null) failed(error);
    log('HTTP请求错误: code=${error.code}, msg=${error.msg}, error=${error.error}');
    return null;
  }

  /// 下载文件
  /// [url] 下载文件的url
  /// [savePath] 保存文件的路径
  /// [cancelToken] 取消下载请求的token
  /// [success] 下载成功返回的结果
  /// [progress] 下载的进度
  /// [failed] 下载失败返回的结果
  /// [canCancel] 是否可以取消下载
  Future<void> download(
    String url,
    dynamic savePath, {
    CancelToken? cancelToken,
    Success? success,
    Progress? progress,
    Failed? failed,
    bool canCancel = true,
  }) async {
    HttpError? error;
    try {
      Dio dio = _createDio(baseUrl: _baseUrls.first);
      Response<dynamic> response = await dio.download(
        url,
        savePath,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
        cancelToken: canCancel ? cancelToken : null,
        onReceiveProgress: (int count, int total) {
          // 未实现/禁止取消/通过token取消下载等情况不能再进行处理
          if (progress == null || canCancel && (cancelToken?.isCancelled ?? true)) return;
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
      );
      if (response.statusCode == 200 || response.statusCode == 206) {
        // 下载成功的返回结果
        if (success != null) {
          success(savePath);
        }
      } else {
        // 下载请求失败的错误信息
        error = HttpError(response.statusCode ?? 1000, response.statusMessage ?? '', error.toString());
      }
    } on DioException catch (e) {
      // 下载失败的错误信息
      error = HttpError(1000, e.message ?? '', error.toString());
    }
    // 下载结果
    if (error == null) return;
    if (failed != null) failed(error!);
    log('下载错误: code=${error!.code}, msg=${error!.msg}, error=${error!.error}');
  }

  /// 上传文件
  /// [fileType] 文件类型：0=图片，1=文件，2=视频，3=音频；
  /// [original] 是否是原文件(默认0)：0=不是，1=是;
  /// [sceneType] 使用场景类型(默认0)：0=聊天，1=朋友圈
  /// [cancelToken] 取消上传请求的token
  /// [success] 上传成功返回的结果
  /// [onSendProgress] 上传的进度
  /// [failed] 上传失败返回的结果
  Future<void> upload(
    int fileType,
    String path,
    int original, {
    CancelToken? cancelToken,
    Success? success,
    Progress? progress,
    Failed? failed,
    bool canCancel = true,
  }) async {
    int sceneType = 0;
    MultipartFile multipartFile = MultipartFile.fromFileSync(
      path,
      filename: path.split(Platform.pathSeparator).last,
      contentType: MediaType.parse('multipart/form-data'),
    );
    FormData data = FormData()
      ..files.add(MapEntry('file', multipartFile))
      ..fields.add(MapEntry('original', '$original'))
      ..fields.add(MapEntry('sceneType', '$sceneType'));

    HttpError? error;
    try {
      Dio dio = _createDio(baseUrl: _baseUrls.first);
      final Response response = await dio.request(
        '${_baseUrls.first}fileUpload/upload/$fileType',
        data: data,
        cancelToken: canCancel ? cancelToken : null,
        options: Options(
          method: 'POST',
          // headers: {r'authorization': SpUtil.getToken()},
          contentType: 'multipart/form-data',
        ),
        onSendProgress: (int count, int total) {
          // 未实现/禁止取消/通过token取消下载等情况不能再进行处理
          if (progress == null || canCancel && (cancelToken?.isCancelled ?? true)) return;
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
      );
      log('上传结果: statusCode=${response.statusCode}, statusMessage=${response.statusMessage}, data=${response.data}');
      final value = DataEntity<dynamic>.fromJson(response.data!);
      if (response.statusCode == 200) {
        // 下载成功的返回结果
        if (success != null) {
          success(value.data);
        }
      } else {
        // 下载请求失败的错误信息
        error = HttpError(response.statusCode ?? 1000, response.statusMessage ?? '', error.toString());
      }
      Future.value(value.data);
    } on DioException catch (e) {
      // 下载失败的错误信息
      error = HttpError(1000, e.message ?? '', error.toString());
      Future.value(false);
    }
    // 下载结果
    if (error == null) return;
    if (failed != null) failed(error!);
    log('上传错误: code=${error!.code}, msg=${error!.msg}, error=${error!.error}');
  }

  void log(dynamic text) => _logPrint == null ? null : _logPrint!(text, tag: 'HttpsClient');

  /// 处理异常
  HttpError parse({dynamic error, int? code = 0, String? msg = ''}) {
    if ((code ?? 0) > 0 || (msg ?? '').isNotEmpty) {
      return HttpError(code ?? 0, msg ?? '未知状态码错误', 'HTTP状态码错误');
    }
    _HttpException exception = _HttpException.unknown;
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
            exception = _HttpException.runtime;
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
  unknown(1109, '未知异常'),
  runtime(1120, '运行时的异常');

  final int code;
  final String msg;

  const _HttpException(this.code, this.msg);
}
