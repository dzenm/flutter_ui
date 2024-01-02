import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_router_delegate.dart';
import 'app_router_old_delegate.dart';
import 'app_route_settings.dart';

///
/// Created by a0010 on 2023/12/29 16:23
///
abstract class AppRouter {
  static bool isNewRouter = false;

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
    PageTransitionsBuilder? pageTransitions,
    bool clearStack = false,
  }) async {
    return null;
  }

  Future<T?> pushReplace<T extends Object?, TO extends Object?>(
    String path, {
    dynamic body,
    List<String>? pathSegments,
    PageTransitionsBuilder? pageTransitions,
  }) async {
    return await push<T>(path, body: body, pathSegments: pathSegments, pageTransitions: pageTransitions);
  }

  Future<T?> pushAndRemoveUntil<T>(
    String path, {
    required String predicate,
    dynamic body,
    List<String>? pathSegments,
    PageTransitionsBuilder? pageTransitions,
  }) async {
    return await push<T>(path, body: body, pathSegments: pathSegments, pageTransitions: pageTransitions);
  }

  Future<T?> pushPage<T>(
    Widget newPage, {
    bool clearStack = false,
  }) async {
    return SynchronousFuture(null);
  }
}

typedef PageBuilder = Widget Function(AppRouteSettings settings);

/// 跳转页面的信息
class AppPageConfig {
  final String name;
  final PageBuilder builder;

  AppPageConfig({
    required this.name,
    required this.builder,
  });
}
