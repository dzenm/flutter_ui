import 'package:sqflite/sqflite.dart';

import '../entities/column_entity.dart';
import '../entities/table_entity.dart';
import 'db_base_model.dart';
import 'db_manager.dart';

/// 数据库操作(增删改查), 在model中使用with混入即可。
class DBDao {
  /// 根据数据库名返回数据库的实例
  Future<Database> getDatabase({String? dbName}) async => await DBManager().getDatabase(dbName: dbName);

  /// 删除数据库
  Future<void> dropDatabase() async => await DBManager().drop();

  /// 关闭数据库
  Future<void> closeDatabase() async => await DBManager().close();

  /// 获取数据库名称
  String getDBName() => DBManager().getDBName();

  /// 获取数据库所在的绝对路径
  Future<String> getPath({String? dbName}) async {
    return await DBManager().getPath(dbName: dbName);
  }

  /// 判断数据库中的表是否存在
  Future<bool> isTableExist(String tableName, {String? dbName}) async {
    return await DBManager().isTableExist(tableName, dbName: dbName);
  }

  /// 获取数据库中表每一列的字段名称
  Future<List<ColumnEntity>> getTableColumn(String dbName, String tableName) async {
    return await DBManager().getTableColumn(dbName, tableName);
  }

  /// 获取数据库中的所有表
  Future<List<TableEntity>> getTableList({String? dbName}) async {
    return await DBManager().getTableList(dbName: dbName);
  }

  /// 插入数据
  Future<void> insert<T extends DBBaseModel>(
    dynamic data, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (data == null) return;
    if (data is List) {
      data.forEach((element) async => await DBManager().insertItem(
            element.tableName,
            element.toJson(),
            conflictAlgorithm: conflictAlgorithm,
          ));
    } else if (data is T) {
      await DBManager().insertItem(
        data.tableName,
        data.toJson(),
        conflictAlgorithm: conflictAlgorithm,
      );
    }
  }

  /// 删除数据
  Future<int> delete<T extends DBBaseModel>(
    T? data, {
    Map<String, String>? where,
  }) async {
    if (data == null) return 0;
    return DBManager().deleteItem(
      data.tableName,
      where: where,
    );
  }

  /// 更新数据
  Future<int> update<T extends DBBaseModel>(
    T? data, {
    Map<String, dynamic>? where,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (data == null) return 0;
    return DBManager().updateItem(
      data.tableName,
      data.toJson(),
      where: where ?? {data.primaryKey: data.primaryValue},
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  /// 查询数据
  Future<List<DBBaseModel>> where<T extends DBBaseModel>(
    T? data, {
    Map<String, String>? where,
  }) async {
    if (data == null) return [];
    return DBManager()
        .where(
          data.tableName,
          where: where,
        )
        .then((value) => value.map((e) => data.fromJson(e)).toList());
  }
}
