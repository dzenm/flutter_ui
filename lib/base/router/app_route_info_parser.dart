import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_route_settings.dart';
import 'app_router_delegate.dart';

///
/// Created by a0010 on 2023/6/13 17:01
/// 解决Web版的路由信息解析器。在浏览器地址栏输入URL，无法定位到具体的路由页面；当我们切换到具体的路由页面，地址栏的URL也不会同步发生变化。
class AppRouteInfoParser extends RouteInformationParser<RouteSettings> {
  final Function? logPrint;

  const AppRouteInfoParser({this.logPrint}) : super();

  /// 解析路由信息：浏览器中输入url/在代码中初始化路由
  @override
  Future<RouteSettings> parseRouteInformation(RouteInformation information) async {
    Uri uri = information.uri;
    String path = uri.path;
    final body = information.state;

    log('解析路由信息：uri=${uri.toString()}, state=${information.state}');
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

    return SynchronousFuture(settings);
  }

  /// 恢复路由信息：传入的 [configuration] 从 [AppRouterDelegate.currentConfiguration] 获得
  @override
  RouteInformation? restoreRouteInformation(RouteSettings configuration) {
    if (configuration.name == null) return null;
    log('恢复路由信息：name=${configuration.name}, settings=${configuration.arguments}');
    return RouteInformation(uri: Uri.parse(configuration.name ?? ''), state: configuration.arguments);
  }

  void log(String msg) => logPrint == null ? null : logPrint!(msg, tag: 'AppRouteInfoParser');
}
