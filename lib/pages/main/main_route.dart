import 'package:fluro/fluro.dart';
import 'package:fluro/src/fluro_router.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/widgets/will_pop_scope_route.dart';
import 'package:flutter_ui/pages/common/not_found_page.dart';
import 'package:flutter_ui/pages/common/web_view_page.dart';
import 'package:flutter_ui/pages/main/main_page.dart';

class MainRoute extends BaseRoute {
  static const String notFound = "/main/notFound";
  static const String webView = "/main/webView";
  static const String main = "/main";

  @override
  void initRouter(FluroRouter router) {
    // WebView页面
    router.define(webView, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入WebView页面: $webView");
      String title = params['title']?.first ?? 'Android群英传';
      String url = params['url']?.first ?? 'https://mp.weixin.qq.com/s/JThouwU2kQvlhnHlJRTZ-Q';
      return WebViewPage(title: title, url: url);
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
  }
}
