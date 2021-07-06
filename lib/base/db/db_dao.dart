import 'package:flutter_ui/base/db/db_model.dart';
import 'package:flutter_ui/base/db/sql_manager.dart';
import 'package:sqflite/sqflite.dart';

/// 数据库操作(增删改查), 在model中使用with混入即可。
class DBDao {
  Future<void> insertItem<T extends BaseDB>(
    dynamic data, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (data == null) return;
    if (data is List) {
      data.forEach((element) async => await SqlManager().insertItem(
            element.getTableName(),
            element.toJson(),
            conflictAlgorithm: conflictAlgorithm,
          ));
    } else if (data is T) {
      await SqlManager().insertItem(
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
    return SqlManager().deleteItem(
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
    return SqlManager().updateItem(
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
    return SqlManager()
        .where(
          data.getTableName(),
          where: where,
        )
        .then((value) => value.map((e) => data.fromJson(e)).toList());
  }
}
