import 'dart:io';

// ignore_for_file: depend_on_referenced_packages
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../base/utils/util.dart';

///
/// Created by a0010 on 2023/2/23 14:10
/// cookie持久化
class CookieInterceptor extends Interceptor {
  CookieInterceptor._privateConstructor();

  static final CookieInterceptor _instance = CookieInterceptor._privateConstructor();

  static get instance => _instance;

  factory CookieInterceptor() => _instance;

  String? _cookie;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 200) {
      _saveCookies(response);
    } else if (response.statusCode == 401) {
      _cookie = null;
      SpUtil.setCookie(_cookie);
    }
    super.onResponse(response, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _setCookies(options);
    return super.onRequest(options, handler);
  }

  Future<void> _saveCookies(Response response) async {
    // set-cookie: [
    //   JSESSIONID=30E02ED9BC323DB4C22C16F6222103AD; Path=/; Secure; HttpOnly,
    //   loginUserName=FreedomEden; Expires=Sun, 26-Mar-2023 08:34:17 GMT; Path=/,
    //   token_pass=43ccc3e2db90ae005b0113683b07aabb; Expires=Sun, 26-Mar-2023 08:34:17 GMT; Path=/,
    //   loginUserName_wanandroid_com=FreedomEden; Domain=wanandroid.com; Expires=Sun, 26-Mar-2023 08:34:17 GMT; Path=/,
    //   token_pass_wanandroid_com=43ccc3e2db90ae005b0113683b07aabb; Domain=wanandroid.com; Expires=Sun, 26-Mar-2023 08:34:17 GMT; Path=/
    // ]
    List<String>? cookies = response.headers.map[HttpHeaders.setCookieHeader];
    if (cookies?.isNotEmpty ?? false) {
      cookies?.removeAt(0);
    }
    if (cookies != null && cookies.isNotEmpty) {
      // 将list类型的cookie转化成string类型
      _cookie = StrUtil.listToString(cookies, pattern: '&');

      SpUtil.setCookie(_cookie);
    }
  }

  Future<void> _setCookies(RequestOptions options) async {
    _cookie = _cookie ?? SpUtil.getCookie();

    // 将string类型的cookie转化成list
    List<String> cookies = StrUtil.stringToList(_cookie, pattern: '&');

    if (kIsWeb) {
      options.headers[HttpHeaders.authorizationHeader] = cookies;
    } else {
      options.headers[HttpHeaders.cookieHeader] = cookies;
    }
  }
}
