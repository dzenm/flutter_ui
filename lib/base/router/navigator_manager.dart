import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/router/route_manager.dart';

import '../../main.dart';

/// 路由跳转工具类
class NavigatorManager {
  static NavigatorState get _state => navigator.currentState!;

  static void navigateTo(
    BuildContext context,
    String path, {
    Object? argument,
    Function(Object)? function,
    bool rootNavigator = false,
    bool clearStack = false,
    bool replace = false,
    Duration? transitionDuration,
    TransitionType? transition = TransitionType.cupertino,
    RouteTransitionsBuilder? transitionBuilder,
  }) {
    // 让页面失去焦点的控制
    FocusScope.of(context).unfocus();
    RouteSettings routeSettings = RouteSettings(arguments: argument);
    if (argument != null && function != null) {
      RouteManager.router
          .navigateTo(
        context,
        path,
        routeSettings: routeSettings,
        rootNavigator: rootNavigator,
        clearStack: clearStack,
        replace: replace,
        transitionDuration: transitionDuration,
        transition: transition,
        transitionBuilder: transitionBuilder,
      )
          .then((value) {
        if (value == null) {
          return;
        }
        function(value);
      }).catchError((onError) {
        Log.d("页面跳转错误: $onError");
      });
    } else if (function != null) {
      RouteManager.router
          .navigateTo(
        context,
        path,
        rootNavigator: rootNavigator,
        clearStack: clearStack,
        replace: replace,
        transitionDuration: transitionDuration,
        transition: transition,
        transitionBuilder: transitionBuilder,
      )
          .then((value) {
        if (value == null) {
          return;
        }
        function(value);
      }).catchError((onError) {
        Log.d("页面跳转错误: $onError");
      });
    } else if (argument != null) {
      RouteManager.router.navigateTo(
        context,
        path,
        routeSettings: routeSettings,
        replace: replace,
        rootNavigator: rootNavigator,
        clearStack: clearStack,
        transitionDuration: transitionDuration,
        transition: transition,
        transitionBuilder: transitionBuilder,
      );
    } else {
      RouteManager.router.navigateTo(
        context,
        path,
        rootNavigator: rootNavigator,
        clearStack: clearStack,
        replace: replace,
        transitionDuration: transitionDuration,
        transition: transition,
        transitionBuilder: transitionBuilder,
      );
    }
  }

  static void finish(BuildContext context, {result}) {
    FocusScope.of(context).unfocus();
    if (result == null) {
      Navigator.pop(context);
    } else {
      Navigator.pop(context, result);
    }
  }

  static String changeToNavigatorPath(String registerPath, {Map<String, dynamic>? params}) {
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

  static Future<dynamic> push(Widget page, {bool isMaterial = false}) {
    return _state.push(_getPageRoute(page, isMaterial));
  }

  static void pop({dynamic result}) {
    FocusScope.of(_state.context).unfocus();
    _state.pop(result);
  }

  static Future<dynamic> pushReplacement(Widget page, {bool isMaterial = false}) {
    return _state.pushReplacement(_getPageRoute(page, isMaterial));
  }

  static Future<dynamic> pushAndRemoveUntil(Widget page, {bool isMaterial = false}) {
    return _state.pushAndRemoveUntil(_getPageRoute(page, isMaterial), (Route<dynamic> route) => false);
  }

  static PageRoute _getPageRoute(Widget page, bool isMaterial) {
    if (isMaterial) {
      return MaterialPageRoute(
        builder: (BuildContext context) => page,
        settings: RouteSettings(name: page.toStringShort()),
      );
    } else {
      return CupertinoPageRoute(
        builder: (BuildContext context) => page,
        settings: RouteSettings(name: page.toStringShort()),
      );
    }
  }
}
