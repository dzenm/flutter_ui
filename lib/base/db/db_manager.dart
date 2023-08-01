import 'package:flutter/foundation.dart';
// ignore_for_file: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'column_entity.dart';
import 'db_sql.dart';
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
  DBManager._internal();

  static final DBManager _instance = DBManager._internal();

  static DBManager get instance => _instance;

  factory DBManager() => _instance;

  Database? _database;

  /// 数据库路径
  String? _dbPath;

  /// 数据库名称，根据用户信息设置，如果不设置，默认使用userId
  String _userId = 'userId';

  set userId(String userId) {
    _userId = userId;
  }

  /// 日志打印，如果不设置，将不打印日志，如果要设置在使用数据库之前调用 [init]
  Function? _logPrint;

  void init({Function? logPrint}) {
    _logPrint = logPrint;
    sqfliteFfiInit();

  }

  /// 获取当前数据库对象, 未指定数据库名称时默认为用户名 [_userId]，切换数据库操作时要先关闭 [close] 再重新打开。
  Future<Database?> getDatabase({String? dbName}) async {
    if (_database == null) {
      var databaseFactory = databaseFactoryFfi;
       databaseFactory.openDatabase(inMemoryDatabasePath);
      String path = await getPath(dbName: dbName);
      _database = await openDatabase(
        path,
        version: Sql.dbVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }
    return _database!;
  }

  /// 当数据库不存在时调用并进行创建, 只在创建第一次时调用
  void _onCreate(Database db, int version) async {
    log('创建数据库 initVersion=$version');

    // 创建数据表
    for (String sql in Sql.createTables) {
      await _createTable(db, sql: sql);
    }
  }

  /// 当数据库版本变化时调用并进行升级，所有数据库变动均需通过代码更新
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    log('升级数据库 oldVersion=$oldVersion, newVersion=$newVersion');

    // 方式一，使用sql进行更新。
    Batch batch = db.batch();
    for (UpgradeDatabase upgradeDatabase in Sql.upgrades) {
      List<String> list = upgradeDatabase(oldVersion, newVersion);
      if (list.isEmpty) continue;
      for (var sql in list) {
        batch.execute(sql);
      }
    }
    // 方式二，通过创建临时表更新
    await batch.commit();
    log('升级数据库完成');
  }

  /// 删除数据库 [_userId]
  Future<void> drop() async {
    String path = await getPath();
    await deleteDatabase(path).then((value) => log('删除数据库成功'));
  }

  /// 关闭数据库
  Future<void> close() async {
    // 如果数据库存在，而且数据库没有关闭，关闭数据库
    if (_database != null && _database!.isOpen) {
      await _database?.close().then((value) => _database = null);
      log('关闭数据库');
    }
  }

  /// 获取数据库 [_userId] 的路径 [_dbPath]
  Future<String> getPath({String? dbName}) async {
    String path = await databasesPath;
    if (_dbPath == null) {
      dbName ??= 'db_$_userId.db';
      log('数据库路径=$path, 数据库名称=$dbName');
      _dbPath = join(path, dbName);
    }
    return _dbPath!;
  }

  Future<String> get databasesPath async => await getDatabasesPath();

  /// 判断表是否存在
  Future<bool> isTableExist(String tableName, {String? dbName}) async {
    Database? db = await getDatabase(dbName: dbName);
    if (db == null) return false;
    List list = await db.rawQuery("${Sql.selectAllTable} AND NAME='$tableName'");
    return list.isNotEmpty;
  }

  /// 如果表不存在，进行创建表
  Future<void> checkTable(String tableName, String columnString, {String? dbName}) async {
    bool existTable = await isTableExist(tableName);
    if (!existTable) {
      await _createTable(_database!, tableName: tableName, columnString: columnString);
    }
  }

  /// 创建新表, 参数[tableName] 和 [columnString] 通过拼接一起使用, 参数[sql]通过自定义创建新表。
  Future<void> _createTable(Database db, {String? tableName, String? columnString, String? sql}) async {
    String sqlString = sql ?? '${Sql.createTable} $tableName ($columnString)';
    await db.execute(sqlString).then((value) => log('创建${tableName ?? '新'}表: $sqlString'));
  }

  /// 获取数据库中表的所有列结构的数据
  Future<List<ColumnEntity>> getTableColumn(String dbName, String tableName) async {
    Database? db = await getDatabase(dbName: dbName);
    if (db == null) return [];
    List list = await db.rawQuery('${Sql.pragmaTable}($tableName)');
    log('查询表列名: $list');
    return list.map((e) => ColumnEntity.fromJson(e)).toList();
  }

  /// 获取数据中所有表的数据
  Future<List<TableEntity>> getTableList({String? dbName}) async {
    Database? db = await getDatabase(dbName: dbName);
    if (db == null) return [];
    List<dynamic> list = await db.rawQuery(Sql.selectAllTable);
    log('查询所有表: $list');
    return list.map((element) => TableEntity.fromJson(element)).toList();
  }

  /// 插入数据
  Future<int> insertItem(
    String tableName,
    Map<String, dynamic> values, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    Database? db = await getDatabase();
    if (db == null) return -1;

    int id = 0;
    id = await db.insert(
      tableName,
      values,
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
    );
    log('表$tableName新增数据 id=$id, data=$values ');
    return id;
  }

  /// 删除数据，当key和value存在时，删除对应表中的数据，当key和value不存在时，删除该表
  Future<int> deleteItem(
    String tableName, {
    Map<String, String>? where,
  }) async {
    Database? db = await getDatabase();
    if (db == null) return -1;

    int count = 0;
    if (where == null) {
      count = await db.delete(tableName);
    } else {
      StringBuffer params = StringBuffer();
      StringBuffer whereString = StringBuffer();
      List<String> whereArgs = [];
      _handleMap(where, whereArgs, whereString, params);
      count = await db.delete(
        tableName,
        where: whereString.toString(),
        whereArgs: whereArgs,
      );
      log('表$tableName 符合 ${params.toString()} 条件共删除数据$count条');
    }
    return count;
  }

  /// 更新数据，更新对应key和value表中的数据
  Future<int> updateItem(
    String tableName,
    Map<String, dynamic> values, {
    Map<String, dynamic>? where,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    Database? db = await getDatabase();
    if (db == null) return -1;

    StringBuffer params = StringBuffer();
    StringBuffer whereString = StringBuffer();
    List<String> whereArgs = [];
    _handleMap(where, whereArgs, whereString, params);
    int count = 0;
    // 更新数据
    count = await db.update(
      tableName,
      values,
      where: whereString.toString(),
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
    );
    log('表$tableName 符合 ${params.toString()} 条件共更新数据$count条');
    return count;
  }

  /// 查询数据，当key和value存在时，查询对应表中的数据，当key和value不存在时，查询对应表中所有数据
  Future<List<Map<String, dynamic>>> where(
    String tableName, {
    Map<String, String>? where,
  }) async {
    Database? db = await getDatabase();
    if (db == null) return [];

    List<Map<String, dynamic>> list = [];

    if (where == null) {
      list = await db.query(tableName);
      log('表$tableName查询数据${list.length}条, data=$list');
    } else {
      StringBuffer paramsString = StringBuffer();
      StringBuffer whereString = StringBuffer();
      List<String> whereArgs = [];
      _handleMap(where, whereArgs, whereString, paramsString);

      list = await db.query(
        tableName,
        where: whereString.toString(),
        whereArgs: whereArgs,
      );
      log('表$tableName 符合 ${paramsString.toString()} 条件共查询数据${list.length}条, data=$list');
    }

    // map转换为List集合
    return list;
  }

  void _handleMap(
    Map<String, dynamic>? whereMap,
    List<String> whereArgs,
    StringBuffer where,
    StringBuffer paramsString,
  ) {
    whereMap?.forEach((key, value) {
      if (where.isNotEmpty) where.write(',');
      where.write('$key = ?');
      whereArgs.add(value);
      paramsString.write('key=$key, value=$value');
    });
  }

  void log(String text) => _logPrint == null ? null : _logPrint!(text, tag: 'DBManager');
}
