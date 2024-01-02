import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../log/log.dart';
import 'app_router_delegate.dart';
import 'app_route_settings.dart';
import 'app_router.dart';

///
/// 路由管理工具类
/// 如果需要打印日志要先初始化
///  AppRouterOldDelegate.init(logPrint: Log.i);
class AppRouterOldDelegate implements AppRouter {
  /// 页面跳转时使用该方法获取 [AppRouterDelegate]
  static AppRouterOldDelegate of(BuildContext context) {
    return AppRouterOldDelegate._internal(context);
  }

  BuildContext context;

  AppRouterOldDelegate._internal(this.context);

  @override
  bool canPop() {
    return Navigator.of(context).canPop();
  }

  /// 返回上一个页面，例：A->B->C->D, 现在在D页面调用pop回到C页面
  @override
  void pop<T extends Object?>([T? result]) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(result);
  }

  @override
  Future<bool> maybePop<T extends Object?>([T? result]) {
    return Navigator.of(context).maybePop(result);
  }

  /// 返回指定页面，例：A->B->C->D, 现在在D页面调用popUntil, 设置router.settings.name == 'A'，回到A页面
  @override
  Future<dynamic> popUntil(String predicate) async {
    FocusScope.of(context).unfocus();
    Navigator.of(context).popUntil(ModalRoute.withName(predicate));
  }

  @override
  Future<T?> pushAndRemoveUntil<T>(String path, {required String predicate, body, List<String>? pathSegments, PageTransitionsBuilder? pageTransitions}) {
    // 打开指定页面(同时指定到当前页面会被销毁)，例：A->B->C->D，由D页面进入A页面，B、C、D页面被销毁，打开A页面
    AppRouteSettings settings = AppRouteSettings.parse(
      path,
      pathSegments: pathSegments,
      body: body,
    );
    _log('进入页面：page=${settings.name}');
    return Navigator.of(context).pushNamedAndRemoveUntil<T>(path, (route) => route.settings.name == predicate, arguments: settings);
  }

  @override
  Future<T?> pushReplace<T extends Object?, TO extends Object?>(String path, {body, List<String>? pathSegments, PageTransitionsBuilder? pageTransitions}) {
    // 打开下一个页面(同时当前页面会被销毁)，例：A->B，由A页面进入B页面，A页面被销毁
    AppRouteSettings settings = AppRouteSettings.parse(
      path,
      pathSegments: pathSegments,
      body: body,
    );
    _log('进入页面：page=${settings.name}');
    return Navigator.of(context).pushReplacementNamed<T, TO>(path, arguments: settings);
  }

  @override
  Future<T?> push<T>(
    String path, {
    List<String>? pathSegments,
    dynamic body,
    PageTransitionsBuilder? pageTransitions,
    bool clearStack = false,
  }) async {
    // 打开下一个页面，例：A->B，由A页面进入B页面
    AppRouteSettings settings = AppRouteSettings.parse(
      path,
      pathSegments: pathSegments,
      body: body,
    );
    _log('进入页面：page=${settings.name}');
    return Navigator.of(context).pushNamed<T>(path, arguments: settings);
  }

  /// 打开一个新的页面
  @override
  Future<T?> pushPage<T>(
    Widget newPage, {
    bool clearStack = false,
  }) async {
    Route<T> route = _buildDefaultRoute<T>(newPage, false, null);
    if (clearStack) {
      // 打开指定页面(同时指定到当前页面会被销毁)，例：A->B->C->D，由D页面进入A页面，B、C、D页面被销毁，打开A页面
      // (Route route) => false 返回为false表示删除路由栈中的所有路由，返回true为不删除路由栈中的所有路由
      return Navigator.pushAndRemoveUntil<T>(context, route, (route) => route.settings.name == newPage.toStringShort());
    }
    // 打开下一个页面，例：A->B，由A页面进入B页面
    return Navigator.push<T>(context, route);
  }

  /// 创建默认的页面跳转动画
  PageRoute<T> _buildDefaultRoute<T>(Widget page, bool isMaterial, Object? args) {
    _log("打开新页面: RouterSettingsName=${page.toStringShort()}${args == null ? '' : ', args=${jsonEncode(args)}'}");
    // return FadeRoute(builder: (context) => page);
    if (isMaterial) {
      return createMaterialRoute<T>(page, args: args);
    } else {
      return createCupertinoRoute<T>(page, args: args);
    }
  }

  /// 将map转化为路径
  String path2Map(String registerPath, {Map<String, dynamic>? params}) {
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
    _log("传递的参数: $result");
    return "$registerPath?$result";
  }

  PageRoute<T> createMaterialRoute<T>(Widget child, {Object? args}) {
    return MaterialPageRoute<T>(
      builder: (BuildContext context) => child,
      settings: RouteSettings(name: child.toStringShort(), arguments: args),
    );
  }

  PageRoute<T> createCupertinoRoute<T>(Widget child, {Object? args}) {
    return CupertinoPageRoute<T>(
      builder: (BuildContext context) => child,
      settings: RouteSettings(name: child.toStringShort(), arguments: args),
    );
  }

  void _log(String msg) => Log.d(msg, tag: 'AppRouterOldDelegate');
}

/// 注册路由信息
class AppRouterOldRegister {
  static final router = AppRouterOldRegister._internal();

  factory AppRouterOldRegister() => router;

  AppRouterOldRegister._internal();

  /// 保存所有注册的路由信息
  final Map<String, AppPageConfig> _routers = {};

  /// 针对命名路由，跳转前拦截操作,找不到路由的时候才会走这里
  Route<dynamic>? generator(RouteSettings settings) {
    String? name = settings.name;
    if (name == null) {
      return null;
    }
    AppPageConfig? config = _routers[name];
    if (config == null) {
      return null;
    }
    PageBuilder? pagerBuilder = config.builder;

    AppRouteSettings appRouteSettings = AppRouteSettings(originPath: name, arguments: settings.arguments);
    return CupertinoPageRoute(builder: (context) => pagerBuilder(appRouteSettings));
  }

  /// 初始化路由
  void initRouter({required List<AppPageConfig> routers}) {
    for (var router in routers) {
      define(router.name, pageBuilder: router.builder);
    }
  }

  /// 注册路由
  void define(String routePath, {PageBuilder? pageBuilder}) {
    AppPageConfig config = AppPageConfig(name: routePath, builder: pageBuilder!);
    _routers[routePath] = config;
  }
}

/// 自定义页面跳转动画
class CustomRoute extends PageRouteBuilder {
  final Widget child;
  final PageTransition transition;

  CustomRoute({
    required this.child,
    this.transition = PageTransition.fade,
  }) : super(
          transitionDuration: const Duration(seconds: 1), // 设置过度时间
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
                  position: Tween<Offset>(begin: const Offset(-1.0, 0.0), end: const Offset(0.0, 0.0)).animate(
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
