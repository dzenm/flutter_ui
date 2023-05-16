import 'package:flutter/cupertino.dart';

abstract class IRouter {
  void initRouter(AppRouter router);
}

///
/// Created by a0010 on 2023/5/6 13:58
///
class AppRouter {
  static final router = AppRouter._internal();

  factory AppRouter() => router;

  AppRouter._internal();

  /// 保存所有注册的路由信息
  Map<String, PagerBuilder> _routers = {};

  /// 针对命名路由，跳转前拦截操作,找不到路由的时候才会走这里
  Route<dynamic>? generator(RouteSettings settings) {
    String? name = settings.name;
    if (name == null) {
      return null;
    }
    PagerBuilder? pagerBuilder = _routers[name];
    if (pagerBuilder == null) {
      return null;
    }
    return CupertinoPageRoute(builder: (context) => pagerBuilder(context));
  }

  /// 注册路由
  void define(String routePath, {PagerBuilder? pagerBuilder}) {
    _routers[routePath] = pagerBuilder!;
  }
}

/// 创建跳转的页面
typedef PagerBuilder = Widget Function(BuildContext context);
