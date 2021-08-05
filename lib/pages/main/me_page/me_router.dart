import 'package:fluro/fluro.dart';
import 'package:fluro/src/fluro_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/router/route_manager.dart';

import 'city_page/city_page.dart';
import 'convert_page/convert_page.dart';
import 'float_navigation_page/float_navigation_page.dart';
import 'http_page/http_page.dart';
import 'list_page/list_page.dart';
import 'qr_page/qr_page.dart';
import 'setting_page/setting_page.dart';
import 'text_page/text_page.dart';

class MeRouter extends BaseRoute {
  static const String textPage = "/main/me/textPage";
  static const String floatNavigatorPage = "/main/me/floatNavigatorPage";
  static const String convertPage = "/main/me/convertPage";
  static const String httpPage = "/main/me/httpPage";
  static const String listPage = "/main/me/listPage";
  static const String qrPage = "/main/me/qrPage";
  static const String citySelectedPage = "/main/me/citySelectedPage";
  static const String settingPage = "/main/me/settingPage";

  @override
  void initRouter(FluroRouter router) {
    router.define(textPage, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入文本和输入框页面: $textPage");
      return TextPage();
    }));
    router.define(floatNavigatorPage, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入NavigationBar页面: $floatNavigatorPage");
      return FloatNavigationPage();
    }));
    router.define(convertPage, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入字符转化页面: $convertPage");
      return ConvertPage();
    }));
    router.define(httpPage, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入网络请求页面: $httpPage");
      return HTTPListPage();
    }));
    router.define(listPage, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入列表页面: $listPage");
      return ListPage();
    }));
    router.define(qrPage, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入二维码扫描页面: $qrPage");
      return QRPage();
    }));
    router.define(citySelectedPage, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入城市选择页面: $citySelectedPage");
      return CitySelectedPage();
    }));
    router.define(settingPage, handler: Handler(handlerFunc: (BuildContext? context, Map<String, List<String>> params) {
      Log.d("进入主设置页面: $settingPage");
      return SettingPage();
    }));
  }
}
