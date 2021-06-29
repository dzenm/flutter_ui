import 'package:flutter_ui/base/db/db_dao.dart';

/// 数据的基类，数据和实体类的转换，数据库表的信息
abstract class BaseDB with DBDao {
  BaseDB();

  BaseDB.fromJson(Map<String, dynamic> json);

  // 将map类型数据转化为实体类
  BaseDB fromJson(Map<String, dynamic> json);

  // 将实体类转化为map类型数据
  Map<String, dynamic> toJson();

  // 列名字符串，如果字段存在关键字，必须使用双引号转义
  String columnString();

  // 表名
  String getTableName();
}
