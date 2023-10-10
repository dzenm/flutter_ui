import 'dart:convert';

/// 数据的基类，数据和实体类的转换，数据库表的信息
abstract class DBBaseEntity {
  DBBaseEntity();

  /// 将实体类转化为map类型数据
  Map<String, dynamic> toJson();

  /// 创建表sql语句
  String get createTableSql => '';

  /// 表名，获取运行时的当前文件名称，转成小写字母，并将entity后缀删除
  String get tableName {
    String className = runtimeType.toString().replaceAll('Entity', '');
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < className.length; i++) {
      String s = className[i];
      if (s == s.toUpperCase()) {
        sb.write('_');
      }
      sb.write(s.toLowerCase());
    }
    return 't${sb.toString()}';
  }

  /// 主键Id
  Map<String, String> get primaryKey => {};

  /// 将dynamic类型(只处理了string和List类型)转化为List类型
  List<dynamic> toList(dynamic data) {
    if (data is List) return data;
    if (data is String) return jsonDecode(data) as List<dynamic>;
    return [];
  }

  /// 将bool类型转化为int类型
  int boolToInt(bool? value) {
    return (value ?? false) ? 1 : 0;
  }

  /// 将dynamic类型(只处理了bool和int类型)转化为bool类型
  bool toBool(dynamic data) {
    if (data is bool) return data;
    if (data is int) return data == 1;
    return false;
  }

  /// 将List类型转化为string类型
  String toJsonString(List<dynamic> list) {
    try {
      return jsonEncode(list.map((e) => e.toJson()).toList());
    } catch (e) {
      return jsonEncode(list);
    }
  }
}
