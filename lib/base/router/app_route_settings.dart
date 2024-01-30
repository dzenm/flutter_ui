import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/7/6 14:28
///
/// 跳转页面时携带的信息
class AppRouteSettings extends RouteSettings {
  final String path; // 路径，即传入的路径
  final Map<String, dynamic>? paths; // 路径参数
  final Map<String, dynamic>? queries; // 查询参数
  final Object? body; // 隐式参数

  const AppRouteSettings({
    required this.path,
    super.name,
    super.arguments,
    this.paths,
    this.queries,
    this.body,
  });

  List<String> get pathSegments => Uri.parse(path).pathSegments;

  /// 处理 [url] 和 [pathSegments]，转化成 [AppRouteSettings]
  /// [pathSegments] 用于替换 [url] 的占位符，[body] 不会展示在 [name] 里面
  factory AppRouteSettings.parse(String url, {List<String>? pathSegments, dynamic body}) {
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
    String path = u.path;
    // 最终的路径（在路径中存在参数值的需要作调整）
    String parsePath = sb.toString();
    //页面跳转携带的参数
    Map<String, String> queryParams = u.queryParameters;
    return AppRouteSettings(
      path: path,
      name: parsePath,
      arguments: parsePath,
      paths: paths,
      queries: queryParams,
      body: body,
    );
  }

  /// 将 [json] 转为 [AppRouteSettings]
  factory AppRouteSettings.fromJson(Map<String, dynamic> json) {
    return AppRouteSettings(
      path: json['path'],
      name: json['name'],
      arguments: json['arguments'],
      paths: json['paths'],
      queries: json['queries'],
      body: json['body'],
    );
  }

  /// 将 [AppRouteSettings] 转化成 json
  Map<String, dynamic> toJson() => {
        'path': path,
        'name': name,
        'arguments': arguments,
        'paths': paths,
        'queries': queries,
        'body': body,
      };

  @override
  String toString() {
    return '${objectRuntimeType(this, 'AppRouteSettings')}'
        '(path="$path", '
        'name="$name", '
        'arguments=$arguments, '
        'paths=$paths, '
        'queries=$queries, '
        'body=$body,)';
  }
}
