import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 路由管理工具类
/// 如果需要打印日志要先初始化
///   RouteManager.init(logPrint: Log.i);
class RouteManager {
  /// 日志打印，如果不设置，将不打印日志，如果要设置在使用数据库之前调用 [init]
  static Function? _logPrint;

  static void init({Function? logPrint}) {
    _logPrint = logPrint;
  }

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
    log('打开新页面: $routeName${args == null ? '' : ', args=${jsonEncode(args)}'}');
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
    log("打开新页面: RouterSettingsName=${page.toStringShort()}${args == null ? '' : ', args=${jsonEncode(args)}'}");
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
    log("传递的参数: $result");
    return "$registerPath?$result";
  }

  static PageRoute createMaterialRoute(Widget child, {Object? args}) {
    return MaterialPageRoute(
      builder: (BuildContext context) => child,
      settings: RouteSettings(name: child.toStringShort(), arguments: args),
    );
  }

  static PageRoute createCupertinoRoute(Widget child, {Object? args}) {
    return CupertinoPageRoute(
      builder: (BuildContext context) => child,
      settings: RouteSettings(name: child.toStringShort(), arguments: args),
    );
  }

  static void log(String text) => _logPrint == null ? null : _logPrint!(text, tag: 'RouteManager');
}

/// 自定义页面跳转动画
class CustomRoute extends PageRouteBuilder {
  final Widget child;
  final PageTransition transition;

  CustomRoute({
    required this.child,
    this.transition = PageTransition.fade,
  }) : super(
          transitionDuration: Duration(seconds: 1), // 设置过度时间
          pageBuilder: (
            // 上下文和动画
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return child;
          },
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) {
            switch (transition) {
              case PageTransition.fade:
                // 渐变效果
                return FadeTransition(
                  // 从0开始到1
                  opacity: Tween(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation, // 传入设置的动画
                      curve: Curves.fastOutSlowIn, // 设置效果，快进漫出   这里有很多内置的效果
                    ),
                  ),
                  child: child,
                );
              case PageTransition.scale:
                // 缩放动画效果
                return ScaleTransition(
                  scale: Tween(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.fastOutSlowIn,
                    ),
                  ),
                  child: child,
                );
              case PageTransition.rotation:
                // 旋转加缩放动画效果
                return RotationTransition(
                  turns: Tween(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.fastOutSlowIn,
                    ),
                  ),
                  child: ScaleTransition(
                    scale: Tween(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.fastOutSlowIn,
                      ),
                    ),
                    child: child,
                  ),
                );
              case PageTransition.slide:
                // 左右滑动动画效果
                return SlideTransition(
                  // 设置滑动的 X,Y 轴
                  position: Tween<Offset>(begin: Offset(-1.0, 0.0), end: Offset(0.0, 0.0)).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.fastOutSlowIn,
                    ),
                  ),
                  child: child,
                );
            }
          },
        );
}

enum PageTransition {
  fade,
  slide,
  rotation,
  scale,
}
