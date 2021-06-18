import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/db/database/base_db.dart';
import 'package:sqflite/sqflite.dart';

import 'sql_manager.dart';

/// 数据库操作的基类
abstract class DBDao {
  // 表名
  String getTableName();

  // 列名字符串，如果字段存在关键字，必须使用双引号转义
  String columnString();

  // 创建新表
  Future<void> _createTable(Database db) async {
    String sql = 'CREATE TABLE IF NOT EXISTS ${getTableName()} (${columnString()})';
    db.execute(sql).then((value) => Log.d('创建新表: $sql'));
  }

  /// super 函数对父类进行初始化，如果表不存在，进行创建表
  @mustCallSuper
  Future<Database> open() async {
    Database db = await SqlManager().open();
    bool isTableExist = await SqlManager().isTableExist(getTableName());
    if (!isTableExist) {
      await _createTable(db);
    }
    return db;
  }

  Future<void> insertItem<T extends BaseDB>(
    T data, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return SqlManager().insertItem(
      getTableName(),
      data,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  Future<void> deleteItem(
    String key,
    String value,
  ) async {
    return SqlManager().deleteItem(
      getTableName(),
      key: key,
      value: value,
    );
  }

  Future<void> updateItem<T extends BaseDB>(
    T data,
    String key,
    String value, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return SqlManager().updateItem(
      getTableName(),
      data,
      key,
      value,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  Future<List<BaseDB>> queryItems<T extends BaseDB>(
    T data, {
    String? key,
    String? value,
  }) async {
    return SqlManager().queryItems(getTableName(), data, key: key, value: value);
  }
}
