import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_ui/http/api_services.dart';

class ApiClient {
  static const int CONNECT_TIMEOUT = 20000;
  static const int RECEIVE_TIMEOUT = 20000;

  factory ApiClient._instance() => ApiClient._internal();

  static get getInstance => ApiClient._instance();

  late Dio dio;
  late ApiServices apiServices;

  ApiClient._internal() {
    var options = BaseOptions(
      connectTimeout: CONNECT_TIMEOUT,
      receiveTimeout: RECEIVE_TIMEOUT,
      validateStatus: (status) {
        // 不使用http状态码判断状态，使用AdapterInterceptor来处理（适用于标准REST风格）
        return true;
      },
      baseUrl: baseUrl,
    );

    dio = Dio(options);
    // 不验证https证书
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      };
    };
    // log interceptor
    dio.interceptors.add(LogInterceptor());
    apiServices = ApiServices(dio);
  }
}
