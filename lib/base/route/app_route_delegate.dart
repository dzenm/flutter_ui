import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../log/log.dart';

typedef PageBuilder = Widget Function(Map<String, String> queryParams);
typedef RouteBuilder = PageRoute Function(Widget child);

///
/// Created by a0010 on 2023/6/13 16:29
/// 路由管理，基于[ChangeNotifier]管理数据，页面进出栈，需要主动刷新，否则页面调整不起作用，
/// 也可以使用已经封装好的方法 [push]、[pushReplace]、[pushAndRemoveUntil]、[pop]、[popUntil]
class AppRouteDelegate extends RouterDelegate<String> with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// 页面管理栈
  final List<Page> _pages = [];

  /// 注册的所有路由
  final List<AppRoutePage> routers;

  AppRouteDelegate({required this.routers});

  /// 页面跳转时使用该方法获取 [AppRouteDelegate]
  static AppRouteDelegate of(BuildContext context) {
    final delegate = Router.of(context).routerDelegate;
    assert(delegate is AppRouteDelegate);
    return delegate as AppRouteDelegate;
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  /// 全局context
  BuildContext get context => navigatorKey.currentContext!;

  @override
  String? get currentConfiguration => _pages.isEmpty ? null : _pages.last.name;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: List.of(_pages),
      observers: [BotToastNavigatorObserver()],
      onPopPage: _onPopPage,
    );
  }

  /// 是否返回页面
  bool _onPopPage(Route route, dynamic result) {
    if (!route.didPop(result)) return false;

    if (canPop()) {
      _removePage();
      return true;
    }
    return false;
  }

  @override
  Future<void> setInitialRoutePath(String configuration) {
    return setNewRoutePath(configuration);
  }

  @override
  Future<void> setNewRoutePath(String path) {
    debugPrint('setNewRoutePath：path=$path');
    // 打开一个新的页面，由于进入了一个新的页面，同时需要更新ChangeNotifier
    _addPage(path);
    notifyListeners();
    return SynchronousFuture(null);
  }

  /// 打开新的页面
  void _addPage(String path) {
    _pages.add(_createPage(path));
  }

  /// 创建新的页面
  Page _createPage(String url) {
    // 处理请求的参数
    Uri u = Uri.parse(url);
    u.pathSegments;
    String path = u.path;
    Map<String, String> queryParams = u.queryParameters;
    Log.d('解析路径: path=$path, queryParams=$queryParams');
    int index = routers.indexWhere((child) => child.name == path);
    if (index == -1) {
      index = routers.indexWhere((route) => route.name == '/notFound');
    }
    AppRoutePage routePage = routers[index];
    Widget child = routePage.builder(queryParams);
    return CupertinoPage(
      key: Key(path) as LocalKey,
      name: path,
      child: child,
    );
    if (routePage.routeBuilder == null) {
      if (Platform.isAndroid) {
        return MaterialPage(
          key: Key(path) as LocalKey,
          name: path,
          child: child,
        );
      } else if (Platform.isIOS) {
        return CupertinoPage(
          key: Key(path) as LocalKey,
          name: path,
          child: child,
        );
      }
    }
    return CustomPage(
      key: Key(path) as LocalKey,
      name: path,
      route: routePage.routeBuilder!(child),
    );
  }

  @override
  Future<bool> popRoute() {
    // 关闭页面处理
    if (canPop()) {
      // 如果页面栈内不止存在一个页面，直接返回
      _removePage();
      notifyListeners();
      return Future.value(true);
    }
    return _confirmExit();
  }

  /// 是否可以返回
  bool canPop() {
    return _pages.length > 1;
  }

  /// 关闭页面
  void _removePage() {
    _pages.removeLast();
  }

  /// 确认退出
  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
        context: navigatorKey.currentContext!,
        builder: (context) {
          return AlertDialog(
            content: const Text('确定要退出App吗?'),
            actions: [
              TextButton(
                child: const Text('取消'),
                onPressed: () => Navigator.pop(context, true),
              ),
              TextButton(
                child: const Text('确定'),
                onPressed: () => Navigator.pop(context, false),
              ),
            ],
          );
        });
    return result ?? true;
  }

  /// 移除一个页面
  void pop() {
    if (!canPop()) return;
    _removePage();
    notifyListeners();
  }

  /// 移除多个页面，在[predicate]之上的页面全部移出栈
  void popUntil({required String predicate}) {
    if (!canPop()) return;
    _removeUntil(predicate);
    notifyListeners();
  }

  /// 进入下一个页面
  /// [clearStack] 是否清除栈内所有页面
  void push(String path, {bool clearStack = false}) {
    if (clearStack) {
      _pages.clear();
    }
    _addPage(path);
    notifyListeners();
  }

  /// 替换当前页面
  void pushReplace(String path) {
    if (_pages.isNotEmpty) {
      _pages.removeLast();
    }
    push(path);
  }

  /// 进入下一个页面，并且移出[predicate]之上的页面，
  void pushAndRemoveUntil(String path, {required String predicate}) {
    _removeUntil(predicate);
    push(path);
  }

  /// 在[predicate]之上的页面全部移出栈
  void _removeUntil(String predicate) {
    for (int i = _pages.length - 1; i >= 0; i--) {
      if (_pages[i].name == predicate) break;
      _pages.removeLast();
    }
  }
}

class AppRoutePage {
  final String name;
  final PageBuilder builder;
  final RouteBuilder? routeBuilder;

  AppRoutePage({
    required this.name,
    required this.builder,
    this.routeBuilder,
  });
}

/// 自定义页面，包含跳转动画
class CustomPage<T> extends Page<T> {
  final Route<T> route;

  /// {@macro flutter.cupertino.CupertinoRouteTransitionMixin.title}
  final String? title;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  /// Creates a custom page.
  const CustomPage({
    required this.route,
    this.maintainState = true,
    this.title,
    this.fullscreenDialog = false,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  @override
  Route<T> createRoute(BuildContext context) {
    return route;
  }
}
