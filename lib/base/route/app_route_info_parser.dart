import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/6/13 17:01
/// 解决Web版的路由信息解析器。在浏览器地址栏输入URL，无法定位到具体的路由页面；当我们切换到具体的路由页面，地址栏的URL也不会同步发生变化。
class AppRouteInfoParser extends RouteInformationParser<Page<dynamic>> {
  const AppRouteInfoParser() : super();

  @override
  Future<Page<dynamic>> parseRouteInformation(
      RouteInformation routeInformation) async {
    String path = routeInformation.location ?? '/';
    Object? body = routeInformation.state;
    PageTransitionsBuilder? _pageTransitions;
    // Context ctx;
    // if (body != null &&
    //     body is Map &&
    //     body['at'] != null &&
    //     body['path'] != null &&
    //     body['pathParams'] != null &&
    //     body['isDirectly'] != null) {
    //   ctx = Context.fromJson(body);
    // } else {
    //   ctx = Context(
    //     path,
    //     body: body,
    //     isDirectly: true,
    //   );
    // }
    // WidgetBuilder? builder;
    // NavigatorRoute? handler = RRouter._register.match(ctx.uri);
    // if (handler != null) {
    //   final result = await handler(ctx);
    //   if (result is WidgetBuilder) {
    //     builder = result;
    //   } else if (result is Redirect) {
    //     return parseRouteInformation(
    //         RouteInformation(location: result.path, state: body));
    //   }
    //   _pageTransitions = handler.defaultPageTransaction;
    // }
    // _pageTransitions ??= RRouter._defaultTransitionBuilder;
    //
    // builder ??=
    //     (BuildContext context) => RRouter._errorPage.notFoundPage(context, ctx);
    Page<dynamic> configuration = MaterialPage(child: Container());
    return SynchronousFuture(configuration);
  }

  @override
  RouteInformation? restoreRouteInformation(Page<dynamic> configuration) {
    if (configuration.name == null) return null;
    return RouteInformation(location: configuration.name, state: configuration.arguments);
  }
}
