import 'package:fluro/fluro.dart';
import 'package:fluro/src/fluro_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ui/router/impl_router.dart';

import 'login_page.dart';
import 'register_page.dart';

class LoginRoute extends ImplRoute {
  static String login = "/login/login";
  static String register = "/login/register";

  @override
  void initRouter(FluroRouter router) {
    router.define(login, handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return LoginPage();
    }));
    router.define(register, handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return RegisterPage();
    }));
  }
}
