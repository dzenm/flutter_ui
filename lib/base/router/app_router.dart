import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_route_settings.dart';
import 'app_router_delegate.dart';
import 'app_router_old_delegate.dart';

/// 页面构造函数
typedef PageBuilder = Widget Function(AppRouteSettings settings);

/// 路由拦截函数
typedef RouteInterceptor = FutureOr<bool> Function(AppRouteSettings settings);

/// 跳转页面的信息
class AppPageConfig {
  /// 路由路径
  final String path;

  /// 跳转的路由页面构造器
  final PageBuilder builder;

  /// 跳转页面的转场动画构造器
  final PageTransitionsBuilder? pageTransitionsBuilder;

  /// 跳转页面的转场动画时间
  final Duration? transitionDuration;

  /// 是否清空栈内数据
  final bool clearStack;

  /// 路由拦截器
  final List<RouteInterceptor> _interceptors;

  AppPageConfig(
    this.path, {
    required this.builder,
    this.pageTransitionsBuilder,
    this.transitionDuration,
    this.clearStack = false,
    List<RouteInterceptor>? interceptors,
  }) : _interceptors = interceptors ?? [];

  List<RouteInterceptor> get interceptors => _interceptors.toList();

  /// Add [interceptor] and optionally
  /// [handler] in the route chain.
  void addInterceptor(RouteInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  AppPageConfig copyWith() {
    return AppPageConfig(
      path,
      builder: builder,
      pageTransitionsBuilder: pageTransitionsBuilder,
      transitionDuration: transitionDuration,
      clearStack: clearStack,
      interceptors: interceptors,
    );
  }
}

///
/// Created by a0010 on 2023/12/29 16:23
///
mixin class AppRouter {
  static bool isNewRouter = true;

  static AppRouter of(BuildContext context) {
    if (isNewRouter) {
      return AppRouterDelegate.of(context);
    }
    return AppRouterOldDelegate.of(context);
  }

  bool canPop() {
    return false;
  }

  void pop<T extends Object?>([T? result]) async {}

  Future<bool> maybePop<T extends Object?>([T? result]) {
    return SynchronousFuture(false);
  }

  Future<dynamic> popUntil(String predicate) async {
    return SynchronousFuture(null);
  }

  Future<T?> push<T>(
    String path, {
    List<String>? pathSegments,
    dynamic body,
    PageTransitionsBuilder? pageTransitionsBuilder,
    Duration? transitionDuration,
    bool clearStack = false,
  }) async {
    return null;
  }

  Future<T?> pushReplace<T extends Object?, TO extends Object?>(
    String path, {
    dynamic body,
    List<String>? pathSegments,
    PageTransitionsBuilder? pageTransitionsBuilder,
    Duration? transitionDuration,
  }) async {
    return await push<T>(
      path,
      body: body,
      pathSegments: pathSegments,
      pageTransitionsBuilder: pageTransitionsBuilder,
      transitionDuration: transitionDuration,
    );
  }

  Future<T?> pushAndRemoveUntil<T>(
    String path, {
    required String predicate,
    dynamic body,
    List<String>? pathSegments,
    PageTransitionsBuilder? pageTransitionsBuilder,
    Duration? transitionDuration,
  }) async {
    return await push<T>(
      path,
      body: body,
      pathSegments: pathSegments,
      pageTransitionsBuilder: pageTransitionsBuilder,
      transitionDuration: transitionDuration,
    );
  }

  Future<T?> pushPage<T>(
    Widget newPage, {
    bool clearStack = false,
  }) async {
    return SynchronousFuture(null);
  }

  void log(String msg) {}
}

mixin AppRouterMixin on AppRouter {
  @override
  Future<T?> pushPage<T>(Widget newPage, {bool clearStack = false}) {
    return super.pushPage(newPage, clearStack: clearStack);
  }
}
