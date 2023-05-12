import 'package:flutter/material.dart';

import 'route_manager.dart';

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
  Map<String, HandlerPage> _routers = {};

  /// 针对命名路由，跳转前拦截操作,找不到路由的时候才会走这里
  Route<dynamic>? generator(RouteSettings settings) {
    String? name = settings.name;
    if (name == null) {
      return null;
    }

    HandlerPage? pageContentBuilder = _routers[name];
    if (pageContentBuilder == null) {
      return null;
    }
    return pageContentBuilder.route;
  }

  /// 注册路由
  void define(String routePath, {PageRoute? routerBuilder, PagerBuilder? pagerBuilder}) {
    PageRoute? route = routerBuilder;
    if (route == null) {
      if (pagerBuilder == null) {
        return;
      }
      route = RouteManager.createMaterialRoute(pagerBuilder());
    }
    _routers[routePath] = HandlerPage(route: route);
  }
}

/// 路由跳转的页面信息
class HandlerPage {
  PageRoute? route;

  HandlerPage({this.route});
}

/// 创建跳转的页面
typedef PagerBuilder = Widget Function();
