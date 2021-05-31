import 'dart:io';

import 'package:sqflite/sqflite.dart';

class SqlManager {
  static const _VERSION = 14;

  static Database? _database;

  ///初始化
  static init() async {
    var databasesPath = await getDatabasesPath();
    String dbName = getDbName();
    String path = databasesPath + dbName;
    if (Platform.isIOS) {
      path = databasesPath + "/" + dbName;
    }
    _database = await openDatabase(path, version: _VERSION, onCreate: (Database db, int version) async {
      print('dbManager create db $version');
    }, onUpgrade: _onUpgrade);
  }

  static List<dynamic> daoList = [];

  static Map<dynamic, List<String>> classPropertyMap = {};

  static void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (newVersion > oldVersion) {
      var batch = db.batch();
      print('dbManager upgrade db $oldVersion $newVersion');

      migrateDb(db);
      await batch.commit();
    }
  }

  static migrateDb(Database db) {
    Future.forEach(classPropertyMap.keys.toList(), (dynamic element) async {
//      int index = dbclass.indexOf(element);
      String tableName = element!.tablename;
      await element.generateTempTables(db, tableName);
      await element.dropTableString(db, tableName);
      await db.execute(element.createTableString());
      await element.restoreData(db, tableName, classPropertyMap[element]);
    });
  }

  static String getDbName() {
    return "db_userId.db";
  }

  ///判断表是否存在
  static isTableExits(String tableName) async {
    await getCurrentDatabase();
    var res = await _database!.rawQuery("select * from Sqlite_master where type = 'table' and name = '$tableName'");
    return res.length > 0;
  }

  ///获取当前数据库对象
  static Future<Database?> getCurrentDatabase() async {
    if (_database == null) {
      await init();
    }
    return _database;
  }

  ///关闭
  static close() {
    _database?.close();
    _database = null;
  }
}
