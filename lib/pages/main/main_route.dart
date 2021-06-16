import 'package:fluro/fluro.dart';
import 'package:fluro/src/fluro_router.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/widgets/will_pop_scope_route.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/pages/main/main_page.dart';
import 'package:flutter_ui/router/route_manager.dart';

class MainRoute extends BaseRoute {
  static const String main = "/main";

  @override
  void initRouter(FluroRouter router) {
    router.define(main, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入主页面: $main");
      return WillPopScopeRoute(MainPage());
    }));
  }
}
