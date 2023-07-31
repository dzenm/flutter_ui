import 'package:sqflite/sqflite.dart';

import 'db_base_model.dart';
import 'db_manager.dart';

/// 数据库操作(增删改查), 在model中使用with混入即可。
mixin class DBDao {
  /// 插入数据
  Future<void> insert<T extends DBBaseModel>(
    dynamic data, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (data == null) return;
    if (data is List) {
      for (var element in data) {
        await DBManager().insertItem(
            element.tableName,
            element.toJson(),
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
