import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/7/6 14:28
///
/// 跳转页面时携带的信息
class AppRouteSettings extends RouteSettings {
  /// 路由跳转的时间
  final DateTime at;

  /// 通过定义的路由名称解析的路由路径地址：/me/info/editInfo/212
  final String path;

  /// 跳转时携带的隐式参数
  final Object? body;

  /// 是否直接跳转
  final bool isDirectly;

  AppRouteSettings(
    this.path, {
    DateTime? at,
    super.name, // 定义的路由名称：/me/info/editInfo/:id
    super.arguments, // 需要跳转的路由(包含完整的结构数据)：/me/info/editInfo/:id?name=zdt
    this.isDirectly = false,
    this.body,
  }) : at = at ?? DateTime.now();

  /// 当前路径的uri
  Uri get uri => Uri.parse(arguments.toString());

  /// 路由路径中的path参数
  /// 例: path=/main/me/:id/
  ///     name=/main/me/132176723/
  ///     pathSegments={'id': 132176723}
  Map<String, dynamic> get pathSegments {
    Map<String, dynamic> result = {};
    List<String> keys = Uri.parse(super.name ?? '').pathSegments;
    List<String> values = Uri.parse(path).pathSegments;
    for (int i = 0; i < keys.length; i++) {
      if (!keys[i].startsWith(':')) continue;
      String key = keys[i].replaceAll(':', '');
      result[key] = values[i];
    }
    return result;
  }

  /// 路由路径中的query参数
  /// 例子: path=/main/me?id=132176723&name=duy
  ///      queries={'id': 132176723, 'name': 'duy'}
  Map<String, dynamic> get queryParameters => uri.queryParameters;

  /// 处理 [url] 和 [pathSegments]，转化成 [AppRouteSettings]
  /// [pathSegments] 用于替换 [url] 的占位符，[body] 是隐式参数，不会展示在 [name] 里面
  factory AppRouteSettings.parse(String url, {List<String>? pathSegments, dynamic body}) {
    Uri u = Uri.parse(url);
    // 处理路径中的参数
    String path = u.path;
    String parsePath = mergePath(u.pathSegments, pathSegments);
    return AppRouteSettings(
      parsePath,
      name: path,
      arguments: url,
      body: body,
    );
  }

  /// 将 [json] 转为 [AppRouteSettings]
  factory AppRouteSettings.fromJson(Map<String, dynamic> json) {
    return AppRouteSettings(
      json['path'],
      at: DateTime.fromMicrosecondsSinceEpoch(json['at']),
      name: json['name'],
      arguments: json['arguments'],
      body: json['body'],
      isDirectly: json['isDirectly'],
    );
  }

  /// 将 [originPathSegments] 起始为":"的参数值替换为 [realPathSegments] 中的真实值
  static String mergePath(List<String> originPathSegments, List<String>? realPathSegments) {
    StringBuffer sb = StringBuffer();
    if (originPathSegments.isEmpty) {
      sb.write('/');
    } else {
      int i = 0;
      for (var item in originPathSegments) {
        if (!item.startsWith(':')) {
          sb.write('/$item');
          continue;
        }
        if (realPathSegments == null || i >= realPathSegments.length) {
          throw const FormatException('params length error');
        }
        sb.write('/${realPathSegments[i++]}');
      }
    }
    return sb.toString();
  }

  /// 将 [AppRouteSettings] 转化成 json
  Map<String, dynamic> toJson() => {
        'at': at.microsecondsSinceEpoch,
        'path': path,
        'name': name,
        'arguments': arguments,
        'pathSegments': pathSegments,
        'queryParameters': queryParameters,
        'body': body,
        'isDirectly': isDirectly,
      };

  @override
  String toString() {
    return '${objectRuntimeType(this, 'AppRouteSettings')}'
        '(at=$at, '
        'path="$path", '
        'name="$name", '
        'arguments=$arguments, '
        'pathSegments=$pathSegments, '
        'queryParameters=$queryParameters, '
        'body=$body, '
        'isDirectly=$isDirectly)';
  }
}
