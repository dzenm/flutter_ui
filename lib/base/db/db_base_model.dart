import 'dart:convert';

import 'db_dao.dart';

/// 数据的基类，数据和实体类的转换，数据库表的信息
abstract class DBBaseModel with DBDao {
  DBBaseModel();

  DBBaseModel.fromJson(Map<String, dynamic> json);

  /// 将map类型数据转化为实体类
  DBBaseModel fromJson(Map<String, dynamic> json);

  /// 将实体类转化为map类型数据
  Map<String, dynamic> toJson();

  /// 表名，获取运行时的当前文件名称，转成小写字母，并将entity后缀删除
  String get tableName => 't_${runtimeType.toString().toLowerCase().replaceAll('entity', '')}';

  /// 主键ID键
  String get primaryKey => '';

  /// 主键ID值
  String get primaryValue => '';

  /// 将dynamic类型(只处理了string和List类型)转化为List类型
  static List<dynamic> toList(dynamic data) {
    if (data is List) return data;
    if (data is String) return jsonDecode(data) as List<dynamic>;
    return [];
  }

  /// 将bool类型转化为int类型
  static int boolToInt(bool? value) {
    return (value ?? false) ? 1 : 0;
  }

  /// 将dynamic类型(只处理了bool和int类型)转化为bool类型
  static bool toBool(dynamic data) {
    if (data is bool) return data;
    if (data is int) return data == 1;
    return false;
  }

  /// 将List类型转化为string类型
  static String toJsonString(List<dynamic> list) {
    try {
      return jsonEncode(list.map((e) => e.toJson()).toList());
    } catch (e) {
      return jsonEncode(list);
    }
  }
}
