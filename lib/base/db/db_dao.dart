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
      await SqlManager.getInstance.checkTable(data[0].getTableName(), data[0].columnString());
      data.forEach((element) async => await SqlManager().insertItem(
            element.getTableName(),
            element.toJson(),
            conflictAlgorithm: conflictAlgorithm,
          ));
    } else if (data is T) {
      await SqlManager.getInstance.checkTable(data.getTableName(), data.columnString());
      await SqlManager().insertItem(
        data.getTableName(),
        data.toJson(),
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
    await SqlManager.getInstance.checkTable(data.getTableName(), data.columnString());
    return SqlManager().deleteItem(
      data.getTableName(),
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
    await SqlManager.getInstance.checkTable(data.getTableName(), data.columnString());
    return SqlManager().updateItem(
      data.getTableName(),
      data.toJson(),
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
    await SqlManager.getInstance.checkTable(data.getTableName(), data.columnString());
    return SqlManager()
        .queryItem(
          data.getTableName(),
          where: where,
        )
        .then((value) => value.map((e) => data.fromJson(e)).toList());
  }
}
