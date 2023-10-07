// ignore_for_file: depend_on_referenced_packages

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'column_entity.dart';
import 'db_base_entity.dart';
import 'db_manager_delegate.dart';
import 'table_entity.dart';

/// 数据库升级
typedef UpgradeDatabase = List<String> Function(int oldVersion, int newVersion);

/// 数据库管理，包括打开，关闭，创建，升级，增删改查。
/// 如果需要打印日志，在main注册
///   DBManager.instance.init(logPrint: Log.db);
/// 如果需要重新设置数据库的名称
///   DBManager.instance.userId = '123456';
/// 在pubspec.yaml添加下列依赖
/// dependencies:
///  ...
///  # sql
///  sqflite: 2.2.7
///  # 路径选择
//   path_provider: 2.0.14
class DBManager {
  static final DBManager _instance = DBManager._internal();

  static DBManager get instance => _instance;

  factory DBManager() => _instance;

  DBManager._internal() {
    _delegate = DBManagerDelegate();
  }

  late DBManagerDelegate _delegate;

  static const tempSuffix = '_TEMP';

  set userId(String userId) {
    _delegate.userId = userId;
  }

  /// 注册数据表
  List<DBBaseEntity> get tables => _delegate.tables;

  void init({Function? logPrint, List<DBBaseEntity>? tables}) {
    _delegate.init(logPrint: logPrint, tables: tables);
  }

  /// 获取当前数据库对象
  Future<Database?> getDatabase({String? dbName}) async {
    return _delegate.getDatabase(dbName: dbName);
  }

  /// 删除数据库
  Future<void> drop() async {
    await _delegate.drop();
  }

  /// 关闭数据库
  Future<void> close() async {
    await _delegate.close();
  }

  /// 获取数据库
  Future<String> getPath({String? dbName}) async {
    return await _delegate.getPath(dbName: dbName);
  }

  /// 获取数据库所在的路径
  /// macOS/iOS: /Users/a0010/Library/Containers/<package_name>/Data/Documents/databases
  /// Windows:   C:\Users\Administrator\Documents
  /// Android:   /data/user/0/<package_name>/databases
  Future<String> get databasesPath async => await _delegate.databasesPath;

  /// 判断表是否存在
  Future<bool> isTableExist(String tableName, {String? dbName}) async {
    return await _delegate.isTableExist(tableName, dbName: dbName);
  }

  /// 获取数据库中表的所有列结构的数据
  Future<List<ColumnEntity>> getTableColumn(String dbName, String tableName) async {
    return await _delegate.getTableColumn(dbName, tableName);
  }

  /// 获取数据中所有表的数据
  Future<List<TableEntity>> getTableList({String? dbName}) async {
    return await _delegate.getTables(dbName: dbName);
  }

  /// 插入数据
  Future<int> insertItem(
    String tableName,
    Map<String, dynamic> values, {
    String? dbName,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return await _delegate.insertItem(tableName, values, dbName: dbName, conflictAlgorithm: conflictAlgorithm);
  }

  /// 插入数据
  /// 使用
  ///  DBManager().insert(article);
  Future<void> insert<T extends DBBaseEntity>(
    dynamic data, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (data == null) return;
    _handleData<T>(data, (table) async {
      await insertItem(
        table.tableName,
        table.toJson(),
        conflictAlgorithm: conflictAlgorithm,
      );
    });
  }

  /// 删除数据，当key和value存在时，删除对应表中的数据，当key和value不存在时，删除该表
  Future<int> deleteItem(
    String tableName, {
    String? dbName,
    Map<String, dynamic>? where,
  }) async {
    return await _delegate.deleteItem(tableName, dbName: dbName, where: where);
  }

  /// 删除数据
  /// 使用
  ///  DBManager().delete<ArticleEntity>(where: {'id': id});
  Future<int> delete<T extends DBBaseEntity>({
    Map<String, dynamic>? where,
  }) async {
    DBBaseEntity? table = _getRuntimeTableType<T>();
    if (table == null) return 0;
    return await deleteItem(
      table.tableName,
      where: where,
    );
  }

  /// 更新数据，更新对应key和value表中的数据
  Future<int> updateItem(
    String tableName,
    Map<String, dynamic> values, {
    String? dbName,
    Map<String, dynamic>? where,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return await _delegate.updateItem(tableName, values, dbName: dbName, where: where, conflictAlgorithm: conflictAlgorithm);
  }

  /// 更新数据
  /// 使用
  ///  DBManager().update(article);
  Future<int> update<T extends DBBaseEntity>(
    T? data, {
    Map<String, dynamic>? where,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    if (data == null) return 0;
    Map<String, dynamic>? defaultWhere;
    if (data.primaryKey.isNotEmpty && data.primaryValue.isNotEmpty) {
      defaultWhere = {data.primaryKey: data.primaryValue};
    }
    return await updateItem(
      data.tableName,
      data.toJson(),
      where: where ?? defaultWhere,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  /// 查询数据，当key和value存在时，查询对应表中的数据，当key和value不存在时，查询对应表中所有数据
  Future<List<Map<String, dynamic>>> queries(
    String tableName, {
    String? dbName,
    Map<String, dynamic>? where,
    int? limit,
    int? offset,
  }) async {
    return await _delegate.queries(tableName, dbName: dbName, where: where, limit: limit, offset: offset);
  }

  /// 查询数据
  /// 使用
  ///  await DBManager().query<ArticleEntity>();
  Future<List<T>> query<T extends DBBaseEntity>({
    Map<String, dynamic>? where,
    int? limit,
    int? offset,
  }) async {
    DBBaseEntity? table = _getRuntimeTableType<T>();
    if (table == null) return [];
    return await queries(
      table.tableName,
      where: where,
      limit: limit,
      offset: offset,
    ).then((value) => value.map((e) => table.fromJson(e) as T).toList());
  }

  /// 处理数据
  static void _handleData<T extends DBBaseEntity>(dynamic data, void Function(T) result) {
    if (data is List<T>) {
      for (var table in data) {
        result(table);
      }
    } else if (data is T) {
      result(data);
    }
  }

  /// 获取运行时的表类型
  static T? _getRuntimeTableType<T extends DBBaseEntity>() {
    for (var tab in DBManager.instance.tables) {
      if (tab is! T) continue;
      return tab;
    }
    return null;
  }

  void log(String text) => _delegate.log(text);
}
