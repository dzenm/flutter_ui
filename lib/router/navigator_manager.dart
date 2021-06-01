import 'package:fluro/fluro.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/http/log.dart';
import 'package:flutter_ui/router/route_manager.dart';

/// 路由跳转工具类
class NavigatorManager {
  static void push(BuildContext context, String path,
      {Object? argument, Function(Object)? function, bool clearStack = false, bool replace = false, transition: TransitionType.native}) {
    // 让页面失去焦点的控制
    FocusScope.of(context).unfocus();
    RouteSettings routeSettings = RouteSettings(arguments: argument);
    if (argument != null && function != null) {
      RouteManager.router
          .navigateTo(context, path, routeSettings: routeSettings, clearStack: clearStack, replace: replace, transition: transition)
          .then((value) {
        if (value == null) {
          return;
        }
        function(value);
      }).catchError((onError) {
        Log.d("页面跳转错误: $onError");
      });
    } else if (function != null) {
      RouteManager.router.navigateTo(context, path, clearStack: clearStack, replace: replace, transition: transition).then((value) {
        if (value == null) {
          return;
        }
        function(value);
      }).catchError((onError) {
        Log.d("页面跳转错误: $onError");
      });
    } else if (argument != null) {
      RouteManager.router.navigateTo(context, path, routeSettings: routeSettings, replace: replace, clearStack: clearStack, transition: transition);
    } else {
      RouteManager.router.navigateTo(context, path, clearStack: clearStack, replace: replace, transition: transition);
    }
  }

  static void pop(BuildContext context, {result}) {
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
}
