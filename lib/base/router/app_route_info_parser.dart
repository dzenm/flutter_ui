import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../log/log.dart';
import 'app_route_delegate.dart';
import 'app_route_settings.dart';

///
/// Created by a0010 on 2023/6/13 17:01
/// 解决Web版的路由信息解析器。在浏览器地址栏输入URL，无法定位到具体的路由页面；当我们切换到具体的路由页面，地址栏的URL也不会同步发生变化。
class AppRouteInfoParser extends RouteInformationParser<AppRouteInformation> {
  const AppRouteInfoParser() : super();

  /// 解析路由信息：浏览器中输入url/在代码中初始化路由
  @override
  Future<AppRouteInformation> parseRouteInformation(RouteInformation routeInformation) async {
    String path = routeInformation.location ?? '/';
    final body = routeInformation.state;

    log('解析路由信息：location=${routeInformation.location}, state=${routeInformation.state}');
    AppRouteSettings settings;
    if (body != null && body is Map<String, dynamic> && body['originPath'] != null && body['name'] != null) {
      settings = AppRouteSettings.fromJson(body);
    } else {
      settings = AppRouteSettings(
        originPath: path,
        name: path,
        body: body,
      );
    }

    return SynchronousFuture(AppRouteInformation(name: path, settings: settings));
  }

  /// 存储路由信息：传入的 [configuration] 从 [AppRouteDelegate.currentConfiguration] 获得
  @override
  RouteInformation? restoreRouteInformation(AppRouteInformation configuration) {
    if (configuration.name == null) return null;
    log('存储路由信息：name=${configuration.name}, settings=${configuration.settings}');
    return RouteInformation(location: configuration.name, state: configuration.settings);
  }

  void log(String msg) => Log.d(msg, tag: 'AppRouteInfoParser');
}

/// 路由存储的页面信息
class AppRouteInformation {
  String? name;
  AppRouteSettings? settings;

  AppRouteInformation({this.name, this.settings});
}
