import 'package:fluro/fluro.dart';
import 'package:fluro/src/fluro_router.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/pages/main/main_page.dart';
import 'package:flutter_ui/router/impl_router.dart';

class MainRoute extends ImplRoute {
  static const String main = "/main";

  @override
  void initRouter(FluroRouter router) {
    router.define(main, handler: Handler(
        handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return MainPage();
    }));
  }
}
