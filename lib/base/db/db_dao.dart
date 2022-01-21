import 'package:flutter_ui/base/entities/column_entity.dart';
import 'package:flutter_ui/base/entities/table_entity.dart';
import 'package:sqflite/sqflite.dart';

import 'database_manager.dart';
import 'db_model.dart';

/// 数据库操作(增删改查), 在model中使用with混入即可。
class DBDao {
  Future<void> drop() async => await DatabaseManager().delete();

  Future<void> close() async => await DatabaseManager().close();

  String getDBName() => DatabaseManager().getDBName();

  Future<String> getPath({String? dbName}) async {
    return await DatabaseManager().getPath(dbName: dbName);
  }

  Future<bool> isTableExist(String tableName, {String? dbName}) async {
    return await DatabaseManager().isTableExist(tableName, dbName: dbName);
  }

  Future<List<TableEntity>> getTableList({String? dbName}) async {
    return await DatabaseManager().getTableList(dbName: dbName);
  }

  Future<List<ColumnEntity>> getTableColumn(String dbName, String tableName) async {
    return await DatabaseManager().getTableColumn(dbName, tableName);
  }

  Future<void> insert<T extends BaseDB>(
    dynamic data, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (data == null) return;
    if (data is List) {
      data.forEach((element) async => await DatabaseManager().insertItem(
            element.getTableName(),
            element.toJson(),
            conflictAlgorithm: conflictAlgorithm,
          ));
    } else if (data is T) {
      await DatabaseManager().insertItem(
        data.getTableName(),
        data.toJson(),
        conflictAlgorithm: conflictAlgorithm,
      );
    }
  }

  Future<int> delete<T extends BaseDB>(
    T? data, {
    Map<String, String>? where,
  }) async {
    if (data == null) return 0;
    return DatabaseManager().deleteItem(
      data.getTableName(),
      where: where,
    );
  }

  Future<int> update<T extends BaseDB>(
    T? data,
    Map<String, String> where, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (data == null) return 0;
    return DatabaseManager().updateItem(
      data.getTableName(),
      data.toJson(),
      where,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  Future<List<BaseDB>> where<T extends BaseDB>(
    T? data, {
    Map<String, String>? where,
  }) async {
    if (data == null) return [];
    return DatabaseManager()
        .where(
          data.getTableName(),
          where: where,
        )
        .then((value) => value.map((e) => data.fromJson(e)).toList());
  }
}
