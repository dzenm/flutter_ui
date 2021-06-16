import 'package:fluro/fluro.dart';
import 'package:fluro/src/fluro_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/router/route_manager.dart';

import 'login_page.dart';
import 'register_page.dart';

class LoginRoute extends BaseRoute {
  static String login = "/login/login";
  static String register = "/login/register";

  @override
  void initRouter(FluroRouter router) {
    router.define(login, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入登录页面: $login");
      return LoginPage();
    }));
    router.define(register, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入注册页面: $register");
      return RegisterPage();
    }));
  }
}
