import 'dart:ffi';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/app_page.dart';
import 'package:flutter_ui/base/log/log.dart';

import 'app_route_util.dart';
import 'custom_page_route.dart';

typedef PageBuilder = Widget Function(AppRouteSettings settings);

/// 跳转页面的信息
class AppRoutePage {
  final String name;
  final PageBuilder builder;

  AppRoutePage({
    required this.name,
    required this.builder,
  });
}

///
/// Created by a0010 on 2023/6/13 16:29
/// 路由管理，基于[ChangeNotifier]管理数据，页面进出栈，需要主动刷新，否则页面调整不起作用，
/// 也可以使用已经封装好的方法 [pop]、[maybePop]、[popUntil]、[push]、[pushReplace]、[pushAndRemoveUntil]
class AppRouteDelegate extends RouterDelegate<Page<dynamic>> with ChangeNotifier, PopNavigatorRouterDelegateMixin<Page<dynamic>> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// 页面管理栈
  final List<Page<dynamic>> _pages = [];

  AppRouteDelegate({required List<AppRoutePage> routers, String? initialRoute}) {
    // 注册路由信息
    for (var route in routers) {
      AppRouteUtil.register.addRoute(route);
    }
    if (initialRoute != null) {
      push(initialRoute);
    }
  }

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

  /// 获取该值用于报告给引擎，在Web应用中
  @override
  Page<dynamic>? get currentConfiguration => _pages.isEmpty ? null : _pages.last;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: List.of(_pages),
      observers: [BotToastNavigatorObserver()],
      // 是否通知给引擎，主要是在 Web 上面，告诉浏览器 URL 的改变，同步地址
      reportsRouteUpdateToEngine: true,
      onPopPage: _onPopPage,
    );
  }

  /// 初始化路由会调用该方法，无需实现，否则会和 [AppPage] 产生冲突
  @override
  Future<void> setInitialRoutePath(Page<dynamic> configuration) {
    return SynchronousFuture(null);
  }

  /// 新增路由信息：浏览器中输入url/在代码中初始化路由
  /// 配合 [AppRouteInfoParser] 使用，与自定义管理路由栈没有关系
  @override
  Future<Void> setNewRoutePath(Page<dynamic> configuration) async {
    debugPrint('setNewRoutePath：configuration=$configuration');
    // 打开一个新的页面，由于进入了一个新的页面，同时需要更新ChangeNotifier
    dynamic navigateResult = await _pushPage(configuration);
    return SynchronousFuture(navigateResult);
  }

  @override
  Future<bool> popRoute() async {
    // 关闭页面处理
    if (canPop()) {
      _removePage();
      _markNeedsUpdate();
      return Future.value(true);
    }
    return _confirmExit();
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

  /// 是否可以返回
  bool canPop() {
    return _pages.length > 1;
  }

  /// 移除一个页面
  void pop<T extends Object?>([T? result]) async {
    if (!canPop()) return;
    final finder = (_removePage() as CustomPage);
    _markNeedsUpdate();
    Future.delayed(finder.transitionDuration, () {
      finder.completerResult.complete(result);
    });
  }

  /// 移除一个页面(如果存在，移除并返回true，如果不存在，返回false)
  Future<bool> maybePop<T extends Object?>([T? result]) {
    if (canPop()) {
      final finder = _removePage();
      _markNeedsUpdate();
      (finder as CustomPage).completerResult.complete(result);
      return SynchronousFuture(true);
    }
    return SynchronousFuture(false);
  }

  /// 移除多个页面，在[predicate]之上的页面全部移出栈
  Future<dynamic> popUntil(String predicate) async {
    if (!canPop()) return;
    _removeUntil(predicate);
    _markNeedsUpdate();
  }

  /// 进入下一个页面
  /// [clearStack] 是否清除栈内所有页面
  Future<dynamic> push(
    String path, {
    dynamic body,
    List<String>? pathSegments,
    PageTransitionsBuilder? pageTransitions,
    bool clearStack = false,
  }) async {
    if (clearStack) {
      _pages.clear();
    }
    AppRouteSettings settings = AppRouteSettings.convert(
      path,
      pathSegments: pathSegments,
      body: body,
    );
    Page<dynamic> page = AppRouteUtil.createPage(settings, pageTransitions: pageTransitions);
    dynamic navigateResult = await _pushPage(page);
    return SynchronousFuture(navigateResult);
  }

  /// 替换当前页面
  Future<dynamic> pushReplace(
    String path, {
    dynamic body,
    List<String>? pathSegments,
    PageTransitionsBuilder? pageTransitions,
  }) async {
    if (_pages.isNotEmpty) {
      _removePage();
    }
    return await push(path, body: body, pathSegments: pathSegments, pageTransitions: pageTransitions);
  }

  /// 进入下一个页面，并且移出[predicate]之上的页面，
  Future<dynamic> pushAndRemoveUntil(
    String path, {
    required String predicate,
    dynamic body,
    List<String>? pathSegments,
    PageTransitionsBuilder? pageTransitions,
  }) async {
    _removeUntil(predicate);
    return await push(path, body: body, pathSegments: pathSegments, pageTransitions: pageTransitions);
  }

  /// 在[predicate]之上的页面全部移出栈
  Page? _removeUntil(String predicate) {
    for (int i = _pages.length - 1; i >= 0; --i) {
      if (_pages[i].name == predicate) break;
      _removePage();
    }
    return null;
  }

  /// 进入下一个页面
  Future<dynamic> _pushPage(Page<dynamic> page) async {
    Log.d('进入下一个页面：page=${page.name}');
    _pages.add(page);
    _markNeedsUpdate();
    return await (page as CustomPage).completerResult.future;
  }

  /// 关闭页面
  Page _removePage() {
    return _pages.removeLast();
  }

  /// 是否需要更新绘制
  void _markNeedsUpdate() {
    notifyListeners();
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
}
