import 'db_dao.dart';

/// 数据的基类，数据和实体类的转换，数据库表的信息
abstract class DBBaseModel with DBDao {
  DBBaseModel();

  DBBaseModel.fromJson(Map<String, dynamic> json);

  // 将map类型数据转化为实体类
  DBBaseModel fromJson(Map<String, dynamic> json);

  // 将实体类转化为map类型数据
  Map<String, dynamic> toJson();

  // 表名
  String getTableName() => 't_${runtimeType.toString().toLowerCase().replaceAll('entity', '')}';
}
