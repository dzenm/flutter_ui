import 'package:flutter_ui/base/db/db_model.dart';
import 'package:flutter_ui/base/db/sql_manager.dart';
import 'package:sqflite/sqflite.dart';

/// 数据库操作(增删改查), 在model中使用with混入即可。
class DBDao {
  Future<void> insertItem<T extends BaseDB>(
    T? data, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (data == null) return;
    return SqlManager().insertItem(
      data,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  Future<void> deleteItem<T extends BaseDB>(
    T? data, {
    String? key,
    String? value,
  }) async {
    if (data == null) return;
    return SqlManager().deleteItem(
      data,
      key: key,
      value: value,
    );
  }

  Future<void> updateItem<T extends BaseDB>(
    T? data,
    String key,
    String value, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (data == null) return;
    return SqlManager().updateItem(
      data,
      key,
      value,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  Future<List<BaseDB>> queryItems<T extends BaseDB>(
    T? data, {
    String? key,
    String? value,
  }) async {
    if (data == null) return [];
    return SqlManager().queryItems(
      data,
      key: key,
      value: value,
    );
  }
}
