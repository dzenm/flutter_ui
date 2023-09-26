import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'db_base_model.dart';
import 'db_manager.dart';
import 'db_sql.dart';

/// 数据库操作(增删改查)
class DBDao {
  /// 插入数据
  static Future<void> insert<T extends DBBaseModel>(
    dynamic data, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (data == null) return;
    if (data is List<T>) {
      for (var table in data) {
        await DBManager().insertItem(
          table.tableName,
          table.toJson(),
          conflictAlgorithm: conflictAlgorithm,
        );
      }
    } else if (data is T) {
      await DBManager().insertItem(
        data.tableName,
        data.toJson(),
        conflictAlgorithm: conflictAlgorithm,
      );
    }
  }

  /// 删除数据
  static Future<int> delete<T extends DBBaseModel>({
    Map<String, String>? where,
  }) async {
    dynamic table = getTable<T>();
    if (table == null) return 0;
    return DBManager().deleteItem(
      table.tableName,
      where: where,
    );
  }

  /// 更新数据
  static Future<int> update<T extends DBBaseModel>(
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
  static Future<List<T>> where<T extends DBBaseModel>({
    Map<String, String>? where,
  }) async {
    dynamic table = getTable<T>();
    if (table == null) return [];
    return DBManager()
        .where(
          table.tableName,
          where: where,
        )
        .then((value) => value.map((e) => table.fromJson(e) as T).toList());
  }

  static dynamic getTable<T extends DBBaseModel>() {
    for (var tab in Sql.tables) {
      if (tab is! T) continue;
      return tab;
    }
  }
}
