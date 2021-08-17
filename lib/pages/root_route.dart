import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/widgets/will_pop_scope_route.dart';

import 'common/not_found_page.dart';
import 'common/web_view_page.dart';
import 'login/login_page.dart';
import 'login/register_page.dart';
import 'main/main_page.dart';
import 'splash/splash_page.dart';

class RootRoute extends BaseRoute {
  static const String login = "/login/login";
  static const String register = "/login/register";
  static const String splash = "/splash";
  static const String main = "/main";

  static const String notFound = "/main/notFound";
  static const String webView = "/main/webView";

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

    // 主页面
    router.define(splash, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入过渡页面: $splash");
      return SplashPage();
    }));

    // 主页面
    router.define(main, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入主页面: $main");
      return WillPopScopeRoute(MainPage());
    }));

    // 页面未注册出错页面
    router.notFoundHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> parameters) {
      Log.e("页面没有注册，找不到该页面...");
      return NotFoundPage();
    });

    // WebView页面
    router.define(webView, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入WebView页面: $webView");
      String title = params['title']?.first ?? 'title';
      String url = params['url']?.first ?? 'https://www.baidu.com';
      return WebViewPage(title: title, url: url);
    }));
  }
}
