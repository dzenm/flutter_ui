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
            element as T,
            conflictAlgorithm: conflictAlgorithm,
          ));
    } else if (data is T) {
      await SqlManager().insertItem(
        data,
        conflictAlgorithm: conflictAlgorithm,
      );
    }
  }

  Future<int> deleteItem<T extends BaseDB>(
    T? data, {
    String? key,
    String? value,
  }) async {
    if (data == null) return 0;
    return SqlManager().deleteItem(
      data,
      key: key,
      value: value,
    );
  }

  Future<int> updateItem<T extends BaseDB>(
    T? data,
    String key,
    String value, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (data == null) return 0;
    return SqlManager().updateItem(
      data,
      key,
      value,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  Future<List<BaseDB>> queryItem<T extends BaseDB>(
    T? data, {
    Map<String, String>? where,
  }) async {
    if (data == null) return [];
    return SqlManager().queryItem(
      data,
      where: where,
    );
  }
}
