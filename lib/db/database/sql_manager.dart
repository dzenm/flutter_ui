import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/db/database/base_db.dart';
import 'package:flutter_ui/utils/sp_util.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

/// 数据库操作管理
class SqlManager {
  static Database? _database;

  static const _VERSION = 1;

  static const String _TAG = 'SqlManager';

  SqlManager._internal();

  static SqlManager getInstance = SqlManager._internal();

  factory SqlManager() => getInstance;

  /// 获取当前数据库对象
  Future<Database> open() async {
    if (_database == null) {
      Log.d('获取当前数据库对象', tag: _TAG);
      String databasesPath = await getPath();
      _database = await openDatabase(databasesPath, version: _VERSION, onCreate: _onCreate, onUpgrade: _onUpgrade);
    }
    return _database!;
  }

  /// 当数据库不存在时调用并进行创建
  void _onCreate(Database db, int version) async {
    Log.d('_onCreate version=$version', tag: _TAG);
  }

  /// 当数据库版本变化时调用并进行升级
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Log.d('_onUpgrade oldVersion=$oldVersion, newVersion=$newVersion', tag: _TAG);
    if (newVersion > oldVersion) {
      Batch batch = db.batch();
      await migrateDb(db);
      await batch.commit();
    }
  }

  List<dynamic> daoList = [];

  Map<dynamic, List<String>> classPropertyMap = {};

  Future<void> migrateDb(Database db) async {
    Future.forEach(classPropertyMap.keys.toList(), (dynamic element) async {
      // int index = dbclass.indexOf(element);
      String tableName = element.tablename;
      // 创建临时表
      await element.generateTempTables(db, tableName);
      await element.dropTableString(db, tableName);
      await db.execute(element.createTableString());
      await element.restoreData(db, tableName, classPropertyMap[element]);
    });
  }

  /// 删除数据库
  Future<void> delete() async {
    await getPath().then((value) async {
      await deleteDatabase(value).then((value) => Log.d('删除数据库成功', tag: _TAG));
    });
  }

  /// 关闭数据库
  Future<void> close() async {
    // 如果数据库存在，而且数据库没有关闭，先关闭数据库
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  /// 获取数据库名称
  String getDBName() {
    return "db_${SpUtil.getUserId()}.db";
  }

  // 获取数据库的路径
  Future<String> getPath() async {
    String databasesPath = await getDatabasesPath();
    String dbName = getDBName();
    Log.d('数据库路径=$databasesPath, 数据库名称=$dbName}', tag: _TAG);
    return join(databasesPath, dbName);
  }

  /// 判断表是否存在
  Future<bool> isTableExist(String tableName) async {
    Database db = await open();
    List list = await db.rawQuery("SELECT * FROM Sqlite_master WHERE TYPE = 'table' AND NAME = '$tableName'");
    Log.d('数据库表=$tableName${list.isNotEmpty ? '存在' : '不存在'}', tag: _TAG);
    return list.length > 0;
  }

  // 插入数据
  Future<void> insertItem<T extends BaseDB>(
    String tableName,
    T data, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    Database db = await open();
    await db
        .insert(
          tableName,
          data.toJson(),
          conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
        )
        .then((val) => Log.d('插入数据成功: ${data.toJson()}', tag: _TAG));
  }

  /// 删除数据，当key和value存在时，删除对应表中的数据，当key和value不存在时，删除该表
  Future<void> deleteItem(
    String tableName, {
    String? key,
    String? value,
  }) async {
    Database db = await open();

    key = key ?? '';
    value = value ?? '';
    if (key.isEmpty || value.isEmpty) {
      await db.delete(tableName).then((val) => Log.d('删除数据$val条', tag: _TAG));
    } else {
      await db.delete(
        tableName,
        where: '$key = ?',
        whereArgs: [value],
      ).then((val) => Log.d('删除$key=$value数据$val条', tag: _TAG));
    }
  }

  /// 更新数据，更新对应key和value表中的数据
  Future<void> updateItem<T extends BaseDB>(
    String tableName,
    T data,
    String key,
    String value, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    Database db = await open();
    // 更新数据
    await db
        .update(
          tableName,
          data.toJson(),
          where: '$key = ?',
          whereArgs: [value],
          conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
        )
        .then((val) => Log.d('更新$key=$value数据$val条', tag: _TAG));
  }

  // 查询数据，当key和value存在时，查询对应表中的数据，当key和value不存在时，查询对应表中所有数据
  Future<List<BaseDB>> queryItems<T extends BaseDB>(
    String tableName,
    T data, {
    String? key,
    String? value,
  }) async {
    Database db = await open();
    List<Map<String, dynamic>> list = [];

    key = key ?? '';
    value = value ?? '';
    if (key.isEmpty || value.isEmpty) {
      list = await db.query(tableName);
      Log.d('查询${list.length}条数据', tag: _TAG);
    } else {
      list = await db.query(
        tableName,
        where: '$key = ?',
        whereArgs: [value],
      );
      Log.d('查询$key=$value数据${list.length}条$list', tag: _TAG);
    }

    // map转换为List集合
    return List.generate(list.length, (i) => data.fromJson(list[i]));
  }
}
