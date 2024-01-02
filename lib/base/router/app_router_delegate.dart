import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../log/log.dart';
import 'app_route_info_parser.dart';
import 'app_route_settings.dart';
import 'app_router.dart';
import 'custom_page_router.dart';
import 'path_tree.dart';

///
/// Created by a0010 on 2023/6/13 16:29
/// 路由管理，基于[ChangeNotifier]管理数据，页面进出栈，需要主动刷新，否则页面调整不起作用，
/// 也可以使用已经封装好的方法 [pop]、[maybePop]、[popUntil]、[push]、[pushReplace]、[pushAndRemoveUntil]
class AppRouterDelegate extends RouterDelegate<AppRouteInformation> with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRouteInformation> implements AppRouter {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// 路由注册器
  static final AppRouterRegister _register = AppRouterRegister();

  /// 页面管理栈
  final List<Page<dynamic>> _pages = [];

  AppRouterDelegate({required List<AppPageConfig> routers, String? initialRoute}) {
    // 注册路由信息
    for (var route in routers) {
      _register.addRoute(route);
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
  BuildContext get context => navigatorKey.currentContext!;

  /// 获取该值用于报告给引擎，在Web应用中
  @override
  AppRouteInformation? get currentConfiguration {
    if (_pages.isEmpty) {
      return null;
    }
    AppRouteSettings settings = AppRouteSettings.fromJson(_pages.last.arguments as Map<String, dynamic>);
    return AppRouteInformation(name: settings.name, settings: settings);
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
  Future<void> setInitialRoutePath(AppRouteInformation configuration) {
    _log('setInitialRoutePath：configuration=$configuration');
    return SynchronousFuture(null);
  }

  /// 新增路由信息：浏览器中输入url/在代码中初始化路由
  /// 配合 [AppRouteInfoParser] 使用，与自定义管理路由栈没有关系
  @override
  Future<void> setNewRoutePath(AppRouteInformation configuration) async {
    _log('setNewRoutePath：configuration=$configuration');
    // 打开一个新的页面，由于进入了一个新的页面，同时需要更新ChangeNotifier
    await _pushPage(configuration.settings!);
    return SynchronousFuture(null);
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
    dynamic body,
    PageTransitionsBuilder? pageTransitions,
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
    dynamic navigateResult = await _pushPage<T>(settings, pageTransitions: pageTransitions);
    return SynchronousFuture(navigateResult);
  }

  /// 进入下一个页面
  Future<T?> _pushPage<T>(AppRouteSettings settings, {PageTransitionsBuilder? pageTransitions}) async {
    Page<dynamic> page = _register.buildPage(settings, pageTransitions: pageTransitions);
    _log('进入页面：page=${page.name}');
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
    PageTransitionsBuilder? pageTransitions,
  }) async {
    if (_pages.isNotEmpty) {
      _removePage();
    }
    return await push<T>(path, body: body, pathSegments: pathSegments, pageTransitions: pageTransitions);
  }

  /// 进入下一个页面，并且移出[predicate]之上的页面，
  @override
  Future<T?> pushAndRemoveUntil<T>(
    String path, {
    required String predicate,
    dynamic body,
    List<String>? pathSegments,
    PageTransitionsBuilder? pageTransitions,
  }) async {
    _removeUntil(predicate);
    return await push<T>(path, body: body, pathSegments: pathSegments, pageTransitions: pageTransitions);
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
  Page _removePage() {
    Page<dynamic> page = _pages.removeLast();
    _log('关闭页面：page=${page.name}');
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

  void _log(String msg) => Log.d(msg, tag: 'AppRouterDelegate');
}

/// 注册路由信息
class AppRouterRegister {
  final List<AppPageConfig> _routes = [];
  PathTree<AppPageConfig> _routeTree = PathTree<AppPageConfig>();

  /// Register Route
  /// [route] You want to register route.
  void addRoute(AppPageConfig route, {bool isReplaceRouter = true}) {
    if (isReplaceRouter == true) {
      _build();
      AppPageConfig? handler = _routeTree.match(getPathSegments(route.name), 'GET');
      _routes.remove(handler);
    }
    _routes.add(route);
  }

  void _build() {
    _routeTree = PathTree<AppPageConfig>();
    for (AppPageConfig route in _routes) {
      _routeTree.addPathAsSegments(getPathSegments(route.name), route);
    }
  }

  /// match Route handle
  /// [uri] requestUrl
  AppPageConfig? match(Uri uri) {
    AppPageConfig? handler = _routeTree.match(uri.pathSegments, 'GET');
    return handler;
  }

  /// 创建 [CustomPage]
  Page<dynamic> buildPage(AppRouteSettings settings, {PageTransitionsBuilder? pageTransitions}) {
    // 注册的url
    String path = settings.originPath;
    // 查找注册的页面
    AppPageConfig? routePage = match(Uri.parse(path));
    routePage ??= match(Uri.parse('/notFound'));

    return CustomPage<dynamic>(
      child: Builder(builder: (BuildContext context) => routePage!.builder(settings)),
      buildCustomRoute: (BuildContext context, CustomPage<dynamic> page) => PageBasedCustomPageRoute(
        page: page,
        pageTransitionsBuilder: pageTransitions ?? defaultTransitionsBuilder(),
      ),
      key: Key(path) as LocalKey,
      name: path,
      arguments: settings.toJson(),
      restorationId: path,
    );
  }

  List<String> getPathSegments(String url) => Uri.parse(url).pathSegments;
}
