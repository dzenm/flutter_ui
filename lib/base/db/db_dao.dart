import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'db_base_model.dart';
import 'db_manager.dart';

/// 数据库操作(增删改查)
class DBDao {
  /// 插入数据
  static Future<void> insert<T extends DBBaseModel>(
    dynamic data, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (data == null) return;
    _handleData<T>(data, (table) async {
      await DBManager().insertItem(
        table.tableName,
        table.toJson(),
        conflictAlgorithm: conflictAlgorithm,
      );
    });
  }

  /// 更新数据
  static Future<int> update<T extends DBBaseModel>(
    T? data, {
    Map<String, dynamic>? where,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (data == null) return 0;
    return await DBManager().updateItem(
      data.tableName,
      data.toJson(),
      where: where ?? {data.primaryKey: data.primaryValue},
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  /// 删除数据
  static Future<int> delete<T extends DBBaseModel>({
    Map<String, String>? where,
  }) async {
    DBBaseModel? table = _getRuntimeTableType<T>();
    if (table == null) return 0;
    return await DBManager().deleteItem(
      table.tableName,
      where: where,
    );
  }

  /// 查询数据
  static Future<List<T>> query<T extends DBBaseModel>({
    Map<String, String>? where,
    int? limit,
    int? offset,
  }) async {
    DBBaseModel? table = _getRuntimeTableType<T>();
    if (table == null) return [];
    return await DBManager()
        .query(
          table.tableName,
          where: where,
          limit: limit,
          offset: offset,
        )
        .then((value) => value.map((e) => table.fromJson(e) as T).toList());
  }

  /// 处理数据
  static void _handleData<T extends DBBaseModel>(dynamic data, void Function(T) result) {
    if (data is List<T>) {
      for (var table in data) {
        result(table);
      }
    } else if (data is T) {
      result(data);
    }
  }

  /// 获取运行时的表类型
  static T? _getRuntimeTableType<T extends DBBaseModel>() {
    for (var tab in DBManager.instance.tables) {
      if (tab is! T) continue;
      return tab;
    }
    return null;
  }
}
