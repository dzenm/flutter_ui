import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_route_delegate.dart';
import 'custom_page_route.dart';
import 'path_tree.dart';

///
/// Created by a0010 on 2023/7/6 14:28
///
class AppRouteUtil {
  /// 注册路由
  static final RouterRegister register = RouterRegister();

  /// 创建 [CustomPage]
  static CustomPage createPage(AppRouteSettings setting, {PageTransitionsBuilder? pageTransitions}) {
    String path = setting.originPath;
    // 查找注册的页面
    AppRoutePage? routePage = register.match(Uri.parse(path));
    routePage ??= register.match(Uri.parse('/notFound'));

    return CustomPage<dynamic>(
      child: Builder(builder: (BuildContext context) => routePage!.builder(setting)),
      buildCustomRoute: (BuildContext context, CustomPage<dynamic> page) => PageBasedCustomPageRoute(
        page: page,
        pageTransitionsBuilder: pageTransitions ?? defaultTransitionsBuilder(),
      ),
      key: Key(path) as LocalKey,
      name: path,
      arguments: setting.toJson(),
      restorationId: path,
    );
  }
}

/// 跳转页面时携带的信息
class AppRouteSettings extends RouteSettings {
  final String originPath;
  final Map<String, dynamic>? paths;
  final Map<String, dynamic>? params;
  final dynamic body;

  const AppRouteSettings({
    required this.originPath,
    super.name,
    super.arguments,
    this.paths,
    this.params,
    this.body,
  });

  @override
  AppRouteSettings copyWith({
    String? originPath,
    String? name,
    Object? arguments,
    Map<String, dynamic>? paths,
    Map<String, dynamic>? params,
    dynamic body,
  }) {
    return AppRouteSettings(
      originPath: originPath ?? '',
      name: name,
      arguments: arguments,
      paths: paths,
      params: params,
      body: body,
    );
  }

  List<String> get pathSegments => Uri.parse(originPath).pathSegments;

  /// 处理 [url] 和 [segments]，转化成 [AppRouteSettings]
  static AppRouteSettings convert(String url, {List<String>? pathSegments, dynamic body}) {
    Uri u = Uri.parse(url);
    // 处理路径中的参数
    StringBuffer sb = StringBuffer();
    Map<String, dynamic> paths = {};
    if (u.pathSegments.isEmpty) {
      sb.write('/');
    } else {
      int i = 0;
      for (var item in u.pathSegments) {
        if (item.startsWith(':')) {
          if (pathSegments == null || i >= pathSegments.length) {
            throw const FormatException('params length error');
          }
          String key = item.replaceAll(':', '');
          String value = pathSegments[i++];
          paths[key] = value;
          sb.write('/$value');
        } else {
          sb.write('/$item');
        }
      }
    }

    // 原始的路径
    String originPath = u.path;
    // 最终的路径（在路径中存在参数值的需要作调整）
    String path = sb.toString();
    //页面跳转携带的参数
    Map<String, String> queryParams = u.queryParameters;
    return AppRouteSettings(
      originPath: originPath,
      name: path,
      paths: paths,
      params: queryParams,
      body: body,
    );
  }

  factory AppRouteSettings.fromJson(Map<String, dynamic> json) {
    return AppRouteSettings(
      originPath: json['originPath'],
      name: json['name'],
      arguments: json['arguments'],
      paths: json['paths'],
      params: json['params'],
      body: json['body'],
    );
  }

  /// 将 [AppRouteSettings] 转化成 json
  Map<String, dynamic> toJson() => {
        'originPath': originPath,
        'name': name,
        'arguments': arguments,
        'paths': paths,
        'params': params,
        'body': body,
      };

  @override
  String toString() {
    return '${objectRuntimeType(this, 'AppRouteSettings')}("$originPath", "$name", $arguments, $paths, $params, $body,)';
  }
}

/// 注册路由信息
class RouterRegister {
  final List<AppRoutePage> _routes = [];
  PathTree<AppRoutePage> _routeTree = PathTree<AppRoutePage>();

  /// Register Route
  /// [route] You want to register route.
  void addRoute(AppRoutePage route, {bool isReplaceRouter = true}) {
    if (isReplaceRouter == true) {
      _build();
      AppRoutePage? handler = _routeTree.match(getPathSegments(route.name), 'GET');
      _routes.remove(handler);
    }
    _routes.add(route);
  }

  void _build() {
    _routeTree = PathTree<AppRoutePage>();
    for (AppRoutePage route in _routes) {
      _routeTree.addPathAsSegments(getPathSegments(route.name), route);
    }
  }

  /// match Route handle
  /// [uri] requestUrl
  AppRoutePage? match(Uri uri) {
    AppRoutePage? handler = _routeTree.match(uri.pathSegments, 'GET');
    return handler;
  }

  List<String> getPathSegments(String url) => Uri.parse(url).pathSegments;
}
