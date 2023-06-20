import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/6/13 17:01
/// 解决Web版的路由信息解析器。在浏览器地址栏输入URL，无法定位到具体的路由页面；当我们切换到具体的路由页面，地址栏的URL也不会同步发生变化。
class AppRouteInfoParser extends RouteInformationParser<String> {
  const AppRouteInfoParser() : super();

  @override
  Future<String> parseRouteInformation(RouteInformation routeInformation) {
    return SynchronousFuture(routeInformation.location ?? '');
  }

  @override
  RouteInformation restoreRouteInformation(String configuration) {
    return RouteInformation(location: configuration);
  }
// @override
// Future<List<RouteSettings>> parseRouteInformation(RouteInformation routeInformation) {
//   // 帮助我们将一个URL地址转换成路由的状态（即配置信息）
//   // parseRouteInformation方法接收一个RouteInformation类型参数，它描述了一个URL的信息，它包含的两个属性分别是字符串location和动态类型state。
//   // location就是URL的path部分，state是用来保存页面中的状态的，例如页面中有一个输入框，并且输入框中输入了内容，保存到state中，下次恢复页面时，数
//   // 据也可以得到恢复。弄清楚了这个方法的参数，上面的代码实现就很好理解了，我们将URL的path解析成Uri类型，这比直接操作字符串path要更方便，然后根据这
//   // 些path信息，生成对应的路由配置RouteSettings并返回。
//   final uri = Uri.parse(routeInformation.location!);
//   final settings = uri.pathSegments.map((path) {
//     return RouteSettings(
//       name: '/$path',
//       arguments: path == uri.pathSegments.last ? uri.queryParameters : null,
//     );
//   }).toList();
//
//   return Future.value(settings);
// }
//
// @override
// RouteInformation restoreRouteInformation(List<RouteSettings> configuration) {
//   // 帮助我们将路由的状态（配置信息）转换为一个URL地址
//   // 接收一组路由配置信息做参数，我需要根据当前的这些路由配置信息，组合生成一条URL，
//   // 并封装成RouteInformation对象返回。这里返回的URL正是用于更新浏览器的地址栏的URL。
//   final location = configuration.last.name;
//   final arguments = _restoreArguments(configuration.last);
//   return RouteInformation(location: '$location$arguments');
// }
//
// String _restoreArguments(RouteSettings routeSettings) {
//   if (routeSettings.name != '/details') return '';
//   var args = routeSettings.arguments as Map;
//
//   return '?name=${args['name']}&imgUrl=${args['imgUrl']}';
// }
}
