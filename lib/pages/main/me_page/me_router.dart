import 'package:fluro/fluro.dart';
import 'package:fluro/src/fluro_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ui/pages/main/me_page/http_page/http_page.dart';
import 'package:flutter_ui/router/impl_router.dart';

import 'convert_page/convert_page.dart';
import 'float_navigation_page/float_navigation_page.dart';
import 'text_page/text_page.dart';

class MeRouter extends ImplRoute {
  static const String textPage = "/main/me/textPage";
  static const String floatNavigator = "/main/me/floatNavigator";
  static const String convert = "/main/me/convert";
  static const String http = "/main/me/HTTP";

  @override
  void initRouter(FluroRouter router) {
    router.define(textPage, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return TextPage();
    }));
    router.define(floatNavigator, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return FloatNavigationPage();
    }));
    router.define(convert, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return ConvertPage();
    }));
    router.define(http, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      return HTTPPage();
    }));
  }
}
