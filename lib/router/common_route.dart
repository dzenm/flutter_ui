import 'package:fluro/fluro.dart';
import 'package:fluro/src/fluro_router.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/http/log.dart';
import 'package:flutter_ui/pages/not_found/not_found_page.dart';
import 'package:flutter_ui/router/route_manager.dart';

class CommonRoute implements BaseRoute {

  static String notFound = "/me/notFound";

  @override
  void initRouter(FluroRouter router) {
    router.notFoundHandler = Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> parameters) {
      Log.e("页面没有注册，找不到该页面...");
      return NotFoundPage();
    });
  }
}
