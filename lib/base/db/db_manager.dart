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

  ///============================== 基本的数据库操作 ================================

  /// 获取当前数据库对象
  Future<Database?> getDatabase({String? dbName}) async {
    return _delegate.getDatabase(dbName: dbName);
  }

  /// 删除数据库
  Future<void> drop() async => await _delegate.drop();

  /// 关闭数据库
  Future<void> close() async => await _delegate.close();

  /// 获取数据库
  Future<String> getPath({String? dbName}) async => await _delegate.getPath(dbName: dbName);

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
  Future<List<ColumnEntity>> getTableColumns(String dbName, String tableName) async {
    return await _delegate.getTableColumns(dbName, tableName);
  }

  /// 获取数据中所有表的数据
  Future<List<TableEntity>> getTables({String? dbName}) async {
    return await _delegate.getTables(dbName: dbName);
  }

  ///============================== SQL增删改查操作 ================================

  /// 插入数据
  Future<int> insert(
    String tableName,
    Map<String, dynamic> values, {
    String? dbName,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return await _delegate.insert(tableName, values, dbName: dbName, conflictAlgorithm: conflictAlgorithm);
  }

  /// 删除数据
  Future<int> delete(
    String tableName, {
    String? dbName,
    String? where,
    List<Object?>? whereArgs,
  }) async {
    return await _delegate.delete(tableName, dbName: dbName, where: where, whereArgs: whereArgs);
  }

  /// 更新数据
  Future<int> update(
    String tableName,
    Map<String, dynamic> values, {
    String? dbName,
    String? where,
    List<Object?>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    return await _delegate.update(tableName, values, dbName: dbName, where: where, whereArgs: whereArgs, conflictAlgorithm: conflictAlgorithm);
  }

  /// 更新数据
  Future<int> rawUpdate(
    String sql,
    List<Object?>? args, {
    String? dbName,
  }) async {
    return await _delegate.rawUpdate(sql, args, dbName: dbName);
  }

  /// 查询数据
  Future<List<Map<String, dynamic>>> query(
    String tableName, {
    String? dbName,
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    return await _delegate.query(
      tableName,
      dbName: dbName,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// 处理数据
  void _handleSingleData<T extends DBBaseEntity>(dynamic data, void Function(T) result) {
    if (data is List<T>) {
      for (var table in data) {
        result(table);
      }
    } else if (data is T) {
      result(data);
    } else {
      log('插入的数据不是正确的实体类型');
    }
  }

  /// 获取运行时的表类型
  T? _getRuntimeTypeTable<T extends DBBaseEntity>() {
    for (var tab in tables) {
      if (tab is! T) continue;
      return tab;
    }
    return null;
  }

  void log(String text) => _delegate.log(text);
}
