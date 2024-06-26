import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_route_info_parser.dart';
import 'app_route_settings.dart';
import 'app_router.dart';
import 'custom_page.dart';
import 'path_tree.dart';

///
/// Created by a0010 on 2023/6/13 16:29
/// 路由管理，基于[ChangeNotifier]管理数据，页面进出栈，需要主动刷新，否则页面调整不起作用，
/// 也可以使用已经封装好的方法 [pop]、[maybePop]、[popUntil]、[push]、[pushReplace]、[pushAndRemoveUntil]
class AppRouterDelegate extends RouterDelegate<RouteSettings> with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteSettings>, AppRouterRegister implements AppRouter {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// 页面管理栈
  final List<Page<dynamic>> _pages = [];

  final Function? logPrint;

  AppRouterDelegate({
    required List<AppPageConfig> routers,
    String? initialRoute,
    this.logPrint,
  }) {
    // 注册路由信息
    for (var route in routers) {
      addRoute(route);
    }
    if (initialRoute != null) {
      push(initialRoute);
    }
  }

  /// 页面跳转时使用该方法获取 [AppRouterDelegate]
  static AppRouterDelegate of(BuildContext context) {
    final delegate = Router.of(context).routerDelegate;
    assert(delegate is AppRouterDelegate);
    return delegate as AppRouterDelegate;
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  /// 全局context
  BuildContext get context => _navigatorKey.currentContext!;

  /// 获取该值用于报告给引擎，在Web应用中
  @override
  RouteSettings? get currentConfiguration {
    if (_pages.isEmpty) {
      return null;
    }
    Page<dynamic> page = _pages.last;
    Map<String, dynamic> arguments = page.arguments as Map<String, dynamic>;
    AppRouteSettings settings = AppRouteSettings.fromJson(arguments);
    return settings;
  }

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
  Future<void> setInitialRoutePath(RouteSettings configuration) {
    log('setInitialRoutePath：configuration=$configuration');
    return SynchronousFuture(null);
  }

  /// 新增路由信息：浏览器中输入url/在代码中初始化路由，首次进入时会通过这个方法来配置路由站
  /// 配合 [AppRouteInfoParser] 使用，与自定义管理路由栈没有关系
  @override
  Future<void> setNewRoutePath(RouteSettings configuration) async {
    if (_pages.isNotEmpty) {
      final lastRouter = _pages.last;
      if (configuration.name == lastRouter.name) {
        return SynchronousFuture(null);
      }
      if (configuration is CustomPage) {
        final newParams = configuration.arguments as Map;
        if (lastRouter.name == null && newParams['isDirectly']) {
          return SynchronousFuture(null);
        }
      }
    }
    _pages.clear();
    await _pushPage(configuration as AppRouteSettings);
    return SynchronousFuture<void>(null);
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
  @override
  bool canPop() {
    return _pages.length > 1;
  }

  /// 移除一个页面
  @override
  void pop<T extends Object?>([T? result]) async {
    if (!canPop()) return;
    final finder = (_removePage() as CustomPage);
    _markNeedsUpdate();
    Future.delayed(finder.transitionDuration, () {
      finder.completerResult.complete(result);
    });
  }

  /// 移除一个页面(如果存在，移除并返回true，如果不存在，返回false)
  @override
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
  @override
  Future<dynamic> popUntil(String predicate) async {
    if (!canPop()) return;
    _removeUntil(predicate);
    _markNeedsUpdate();
  }

  /// 进入下一个页面
  /// [clearStack] 是否清除栈内所有页面
  @override
  Future<T?> push<T>(
    String path, {
    List<String>? pathSegments,
    body,
    PageTransitionsBuilder? pageTransitionsBuilder,
    Duration? transitionDuration,
    bool clearStack = false,
  }) async {
    if (clearStack) {
      _pages.clear();
    }
    AppRouteSettings settings = AppRouteSettings.parse(
      path,
      pathSegments: pathSegments,
      body: body,
    );
    dynamic navigateResult = await _pushPage<T>(
      settings,
      pageTransitionsBuilder: pageTransitionsBuilder,
      transitionDuration: transitionDuration,
    );
    return SynchronousFuture(navigateResult);
  }

  /// 进入下一个页面
  Future<T?> _pushPage<T>(
    AppRouteSettings settings, {
    Duration? transitionDuration,
    PageTransitionsBuilder? pageTransitionsBuilder,
    bool clearStack = false,
  }) async {
    Page<dynamic> page = buildPage(
      settings,
      pageTransitionsBuilder: pageTransitionsBuilder,
      transitionDuration: transitionDuration,
    );
    log('进入页面：page=${page.name}');
    _pages.add(page);
    _markNeedsUpdate();
    return await (page as CustomPage).completerResult.future;
  }

  /// 替换当前页面
  @override
  Future<T?> pushReplace<T extends Object?, TO extends Object?>(
    String path, {
    dynamic body,
    List<String>? pathSegments,
    PageTransitionsBuilder? pageTransitionsBuilder,
    Duration? transitionDuration,
  }) async {
    if (_pages.isNotEmpty) {
      _removePage();
    }
    return await push<T>(
      path,
      body: body,
      pathSegments: pathSegments,
      pageTransitionsBuilder: pageTransitionsBuilder,
      transitionDuration: transitionDuration,
    );
  }

  /// 进入下一个页面，并且移出[predicate]之上的页面，
  @override
  Future<T?> pushAndRemoveUntil<T>(
    String path, {
    required String predicate,
    dynamic body,
    List<String>? pathSegments,
    PageTransitionsBuilder? pageTransitionsBuilder,
    Duration? transitionDuration,
  }) async {
    _removeUntil(predicate);
    return await push<T>(
      path,
      body: body,
      pathSegments: pathSegments,
      pageTransitionsBuilder: pageTransitionsBuilder,
      transitionDuration: transitionDuration,
    );
  }

  @override
  Future<T?> pushPage<T>(Widget newPage, {bool clearStack = false}) {
    throw UnimplementedError();
  }

  /// 在[predicate]之上的页面全部移出栈
  Page? _removeUntil(String predicate) {
    Page? page;
    for (int i = _pages.length - 1; i >= 0; --i) {
      page = _pages[i];
      if (page.name == predicate) break;
      _removePage();
    }
    return page;
  }

  /// 关闭页面
  Page _removePage({dynamic result}) {
    Page<dynamic> page = _pages.removeLast();
    log('关闭页面：page=${page.name}');
    (page as CustomPage).completerResult.complete(result);
    return page;
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

  @override
  void log(String msg) => logPrint == null ? null : logPrint!(msg, tag: 'AppRouterOldDelegate');
}

/// 注册路由信息
mixin AppRouterRegister {
  final List<AppPageConfig> _routes = [];
  PathTree<AppPageConfig> _routerTree = PathTree<AppPageConfig>();

  ///Register Routes
  /// [routes] You want to register routes.
  void add(Iterable<AppPageConfig> routes) {
    _routes.addAll(routes);
  }

  /// Register Route
  /// [route] You want to register route.
  void addRoute(AppPageConfig route, {bool isReplaceRouter = true}) {
    if (isReplaceRouter == true) {
      _build();
      Uri uri = Uri.parse(route.path);
      AppPageConfig? handler = _routerTree.match(uri.pathSegments, 'GET');
      _routes.remove(handler);
    }
    _routes.add(route);
  }

  void _build() {
    _routerTree = PathTree<AppPageConfig>();
    for (AppPageConfig route in _routes) {
      Uri uri = Uri.parse(route.path);
      _routerTree.addPathAsSegments(uri.pathSegments, route);
    }
  }

  /// match Route handle
  /// [uri] requestUrl
  AppPageConfig? match(Uri uri) {
    AppPageConfig? handler = _routerTree.match(uri.pathSegments, 'GET');
    return handler;
  }

  /// 创建 [CustomPage]
  Page<dynamic> buildPage(
    AppRouteSettings settings, {
    PageTransitionsBuilder? pageTransitionsBuilder,
    Duration? transitionDuration,
    bool clearStack = false,
  }) {
    // 注册的url
    String path = settings.name ?? '';
    // 查找注册的页面
    AppPageConfig? routePage = match(Uri.parse(path));
    routePage ??= match(Uri.parse('/notFound'));

    final interceptor = routePage?.interceptors;
    if (interceptor!.isNotEmpty) {
      // dynamic result;
      // for (final interceptor in interceptor) {
      //   // result = await interceptor(settings);
      //   // if (result == true) {
      //   //   // return ;
      //   // }
      // }
    }

    return CustomPage<dynamic>(
      child: Builder(builder: (BuildContext context) => routePage!.builder(settings)),
      transitionDuration: transitionDuration ?? routePage!.transitionDuration ?? const Duration(milliseconds: 300),
      buildCustomRoute: (BuildContext context, CustomPage<dynamic> page) {
        return PageBasedCustomPageRoute(
          page: page,
          pageTransitionsBuilder: pageTransitionsBuilder ?? routePage?.pageTransitionsBuilder ?? defaultTransitionsBuilder(),
        );
      },
      key: Key(path) as LocalKey,
      name: path,
      arguments: settings.toJson(),
      restorationId: path,
    );
  }
}
