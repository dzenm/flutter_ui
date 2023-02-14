import 'package:flutter_ui/base/config/build_config.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../entities/column_entity.dart';
import '../entities/table_entity.dart';
import '../log/log.dart';
import '../utils/sp_util.dart';
import 'db_sql.dart';

/// 数据库升级
typedef UpgradeDatabase = String? Function(int oldVersion, int newVersion);

/// 数据库管理，包括打开，关闭，创建，升级，增删改查。
class DBManager {
  static const String _tag = 'DBManager';

  DBManager._internal();

  static DBManager getInstance = DBManager._internal();

  factory DBManager() => getInstance;

  Database? _database;

  /// 获取当前数据库对象, 未指定数据库名称时默认为用户名，切换数据库操作时要先关闭再重新打开。
  Future<Database> getDatabase({String? dbName}) async {
    if (_database == null) {
      String path = await getPath(dbName: dbName ?? getDBName());
      _database = await openDatabase(path, version: Sql.dbVersion, onCreate: _onCreate, onUpgrade: _onUpgrade);
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

    Batch batch = db.batch();
    for (UpgradeDatabase upgradeDatabase in Sql.upgrades) {
      String? sql = upgradeDatabase(oldVersion, newVersion);
      if (sql != null) {
        batch.execute(sql);
      }
    }
    await batch.commit();
  }

  /// 删除数据库
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

  /// 获取数据库名称
  String getDBName() {
    return 'db_${SpUtil.getUserId()}.db';
  }

  /// 获取数据库的路径
  Future<String> getPath({String? dbName}) async {
    String databasesPath = await getDatabasesPath();
    dbName = dbName ?? getDBName();
    log('数据库路径=$databasesPath, 数据库名称=$dbName');
    return join(databasesPath, dbName);
  }

  /// 判断表是否存在
  Future<bool> isTableExist(String tableName, {String? dbName}) async {
    Database db = await getDatabase(dbName: dbName);
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
    Database db = await getDatabase(dbName: dbName);
    List list = await db.rawQuery('${Sql.pragmaTable}($tableName)');
    log('查询表列名: $list');
    return list.map((e) => ColumnEntity.fromJson(e)).toList();
  }

  /// 获取数据中所有表的数据
  Future<List<TableEntity>> getTableList({String? dbName}) async {
    Database db = await getDatabase(dbName: dbName);
    List<dynamic> list = await db.rawQuery(Sql.selectAllTable);
    log('查询所有表: $list');
    return list.map((element) => TableEntity.fromJson(element)).toList();
  }

  // 插入数据
  Future<int> insertItem(
    String tableName,
    Map<String, dynamic> values, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    Database db = await getDatabase();

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
    Database db = await getDatabase();

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
    Database db = await getDatabase();

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

  // 查询数据，当key和value存在时，查询对应表中的数据，当key和value不存在时，查询对应表中所有数据
  Future<List<Map<String, dynamic>>> where(
    String tableName, {
    Map<String, String>? where,
  }) async {
    Database db = await getDatabase();

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

  void _handleMap(Map<String, dynamic>? whereMap, List<String> whereArgs, StringBuffer where, StringBuffer paramsString) {
    whereMap?.forEach((key, value) {
      if (where.isNotEmpty) where.write(',');
      where.write('$key = ?');
      whereArgs.add(value);
      paramsString.write('key=$key, value=$value');
    });
  }

  void log(String text) => BuildConfig.showDBLog ? Log.i(text, tag: _tag) : null;
}
