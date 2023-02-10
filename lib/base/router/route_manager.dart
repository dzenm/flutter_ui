import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../log/log.dart';

/// 路由管理工具类
class RouteManager {
  /// 打开一个新的页面
  static Future<dynamic> push(
    BuildContext context,
    Widget newPage, {
    bool replace = false,
    bool clearStack = false,
    bool isMaterial = false,
    Object? args,
  }) {
    Route route = _buildDefaultRoute(newPage, isMaterial, args);
    if (clearStack) {
      // 打开指定页面(同时指定到当前页面会被销毁)，例：A->B->C->D，由D页面进入A页面，B、C、D页面被销毁，打开A页面
      // (Route route) => false 返回为false表示删除路由栈中的所有路由，返回true为不删除路由栈中的所有路由
      return Navigator.pushAndRemoveUntil(context, route, (route) => route.settings.name == newPage.toStringShort());
    } else if (replace) {
      // 打开下一个页面(同时当前页面会被销毁)，例：A->B，由A页面进入B页面，A页面被销毁
      return Navigator.pushReplacement(context, route);
    }
    // 打开下一个页面，例：A->B，由A页面进入B页面
    return Navigator.push(context, route);
  }

  /// 通过路由名称打开页面，See [push]
  static Future<dynamic> pushNamed(
    BuildContext context,
    String routeName, {
    bool replace = false,
    bool clearStack = false,
    bool isMaterial = false,
    Object? args,
  }) {
    Log.i('打开新页面: $routeName${args == null ? '' : ', args=${jsonEncode(args)}'}');
    if (clearStack) {
      // 打开指定页面(同时指定到当前页面会被销毁)，例：A->B->C->D，由D页面进入A页面，B、C、D页面被销毁，打开A页面
      return Navigator.pushNamedAndRemoveUntil(context, routeName, (route) => route.settings.name == routeName, arguments: args);
    } else if (replace) {
      // 打开下一个页面(同时当前页面会被销毁)，例：A->B，由A页面进入B页面，A页面被销毁
      return Navigator.pushReplacementNamed(context, routeName, arguments: args);
    }
    // 打开下一个页面，例：A->B，由A页面进入B页面
    return Navigator.pushNamed(context, routeName, arguments: args);
  }

  /// 返回上一个页面，例：A->B->C->D, 现在在D页面调用pop回到C页面
  static void pop(BuildContext context, [dynamic result]) {
    FocusScope.of(context).unfocus();
    Navigator.pop(context, result);
  }

  /// 返回指定页面，例：A->B->C->D, 现在在D页面调用popUntil, 设置router.settings.name == 'A'，回到A页面
  static void popUntil(BuildContext context, RoutePredicate predicate) {
    FocusScope.of(context).unfocus();
    Navigator.popUntil(context, predicate);
  }

  /// 创建默认的页面跳转动画
  static PageRoute _buildDefaultRoute(Widget page, bool isMaterial, Object? args) {
    Log.i("打开新页面: RouterSettingsName=${page.toStringShort()}${args == null ? '' : ', args=${jsonEncode(args)}'}");
    // return FadeRoute(builder: (context) => page);
    if (isMaterial) {
      return createMaterialRoute(page, args: args);
    } else {
      return createCupertinoRoute(page, args: args);
    }
  }

  /// 将map转化为路径
  static String path2Map(String registerPath, {Map<String, dynamic>? params}) {
    if (params == null || params.isEmpty) {
      return registerPath;
    }
    StringBuffer bufferStr = StringBuffer();
    params.forEach((key, value) {
      bufferStr
        ..write(key)
        ..write("=")
        ..write(Uri.encodeComponent(value))
        ..write("&");
    });
    String paramStr = bufferStr.toString();
    String result = paramStr.substring(0, paramStr.length - 1);
    Log.i("传递的参数: $result");
    return "$registerPath?$result";
  }

  static PageRoute createMaterialRoute(Widget page, {Object? args}) {
    return MaterialPageRoute(
      builder: (BuildContext context) => page,
      settings: RouteSettings(name: page.toStringShort(), arguments: args),
    );
  }

  static PageRoute createCupertinoRoute(Widget page, {Object? args}) {
    return CupertinoPageRoute(
      builder: (BuildContext context) => page,
      settings: RouteSettings(name: page.toStringShort(), arguments: args),
    );
  }
}
