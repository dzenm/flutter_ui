import 'package:fluro/fluro.dart';
import 'package:fluro/src/fluro_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ui/base/http/log.dart';
import 'package:flutter_ui/pages/main/me_page/http_page/http_page.dart';
import 'package:flutter_ui/router/route_manager.dart';

import 'convert_page/convert_page.dart';
import 'float_navigation_page/float_navigation_page.dart';
import 'list_page/list_page.dart';
import 'text_page/text_page.dart';

class MeRouter extends BaseRoute {
  static const String textPage = "/main/me/textPage";
  static const String floatNavigator = "/main/me/floatNavigator";
  static const String convert = "/main/me/convert";
  static const String http = "/main/me/http";
  static const String list = "/main/me/list";

  @override
  void initRouter(FluroRouter router) {
    router.define(textPage, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入文本和输入框页面: $textPage");
      return TextPage();
    }));
    router.define(floatNavigator, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入NavigationBar页面: $floatNavigator");
      return FloatNavigationPage();
    }));
    router.define(convert, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入字符转化页面: $convert");
      return ConvertPage();
    }));
    router.define(http, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入网络请求页面: $http");
      return HTTPPage();
    }));
    router.define(list, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入列表页面: $list");
      return ListPage();
    }));
  }
}
