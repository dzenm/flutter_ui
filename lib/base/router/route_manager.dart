import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/base/log/log.dart';

import '../../main.dart';

/// 路由管理工具类
class RouteManager {
  static NavigatorState get _state => Application.navigatorKey.currentState!;

  static Future<dynamic> push(
    Widget page, {
    bool isMaterial = false,
    bool clearStack = false,
    bool replace = false,
    Object? arguments,
  }) {
    Route route = _getPageRoute(page, isMaterial, arguments);
    if (clearStack) {
      // 删除路由栈中的所有route，然后再弹出新的页面
      // (Route route) => false 返回为false表示删除路由栈中的所有路由，返回true为不删除路由栈中的所有路由
      return _state.pushAndRemoveUntil(route, (Route<dynamic> route) => false);
    } else if (replace) {
      // 将下一个页面插入栈顶的同时，将上一个页面进行移除
      return _state.pushReplacement(route);
    }
    // 将一个元素插入到堆栈的顶部
    return _state.push(route);
  }

  static Future<dynamic> pushNamed(
    String routeName, {
    bool isMaterial = false,
    bool clearStack = false,
    bool replace = false,
    Object? arguments,
  }) {
    Log.d("打开新页面: $routeName");
    if (clearStack) {
      // 删除路由栈中的所有route，然后再弹出新的页面
      // (Route route) => false 返回为false表示删除路由栈中的所有路由，返回true为不删除路由栈中的所有路由
      return _state.pushNamedAndRemoveUntil(routeName, (Route<dynamic> route) => false, arguments: arguments);
    } else if (replace) {
      // 将下一个页面插入栈顶的同时，将上一个页面进行移除
      return _state.pushReplacementNamed(routeName, arguments: arguments);
    }
    // 将一个元素插入到堆栈的顶部
    return _state.pushNamed(routeName, arguments: arguments);
  }

  // 将堆栈的顶部元素进行删除，回退到上一个界面
  static void pop([dynamic result]) {
    FocusScope.of(_state.context).unfocus();
    _state.pop(result);
  }

  static PageRoute _getPageRoute(Widget page, bool isMaterial, Object? arguments) {
    Log.d("打开新页面: ${page.toStringShort()}");
    if (isMaterial) {
      // return FadeRoute(builder: (context) => page);
      return MaterialPageRoute(
        builder: (BuildContext context) => page,
        settings: RouteSettings(name: page.toStringShort(), arguments: arguments),
      );
    } else {
      return CupertinoPageRoute(
        builder: (BuildContext context) => page,
        settings: RouteSettings(name: page.toStringShort(), arguments: arguments),
      );
    }
  }

  static String path2Map(String registerPath, {Map<String, dynamic>? params}) {
    if (params == null || params.isEmpty) {
      return registerPath;
    }
    StringBuffer bufferStr = StringBuffer();
    params.forEach((key, value) {
      bufferStr..write(key)..write("=")..write(Uri.encodeComponent(value))..write("&");
    });
    String paramStr = bufferStr.toString();
    paramStr = paramStr.substring(0, paramStr.length - 1);
    Log.d("传递的参数: $paramStr");
    return "$registerPath?$paramStr";
  }
}
