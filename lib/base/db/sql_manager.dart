import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/utils/sp_util.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import 'db_model.dart';

/// 数据库操作管理
class SqlManager {
  static Database? _database;

  static const _VERSION = 3;

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
    Log.d('Database onCreate version=$version', tag: _TAG);
  }

  /// 当数据库版本变化时调用并进行升级
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    Log.d('Database onUpgrade oldVersion=$oldVersion, newVersion=$newVersion', tag: _TAG);
    // – 修改表名
    // – ALTER TABLE tableName RENAME TO test;

    // – 增加主键
    // – alter table t_test add f int(5) unsigned default 0 not null auto_increment ,add primary key (f);
    // – 修改ID为自增，并设置为主键
    // – alter table t_test modify id int auto_increment primary key;
    //
    // – 增加字段
    // – ALTER TABLE t_test ADD h INT default 0;
    //
    // – 修改字段：after
    // – ALTER TABLE t_test ADD COLUMN d INT DEFAULT ‘0’ COMMENT ’ ’ AFTER a;
    // – ALTER TABLE t_test ADD COLUMN d INT DEFAULT ‘0’ COMMENT ’ ’ AFTER a;
    //
    // – 修改原字段名称及类型
    // – ALTER TABLE t_test CHANGE d e varchar(50) DEFAULT NULL;
    //
    // – 修改一个字段的类型
    // – alter table t_test MODIFY e VARCHAR(100) DEFAULT NULL;
    //
    // – 调整字段顺序
    // – ALTER TABLE t_test CHANGE e e varchar(50) DEFAULT NULL AFTER c;
    //
    // – 删除字段
    // – ALTER TABLE t_test DROP e;
    //
    // – ++ 索引操作
    //
    // – 添加PRIMARY KEY（主键索引）
    // – ALTER TABLE t_test ADD PRIMARY KEY ( e );
    // – 添加UNIQUE(唯一索引)
    // – ALTER TABLE t_test ADD UNIQUE (e);
    // – 添加INDEX(普通索引)
    // – ALTER TABLE t_test ADD INDEX index_name ( e );
    // – 添加FULLTEXT(全文索引)
    // – ALTER TABLE t_test ADD FULLTEXT (e);
    // – 添加多列索引
    // – ALTER TABLE t_test ADD INDEX index_name ( a, b, c )

    await _onUpgrade_1_2(db, oldVersion, newVersion);
    await _onUpgrade_2_3(db, oldVersion, newVersion);
  }

  Future<void> _onUpgrade_1_2(Database db, int oldVersion, int newVersion) async {
    if (newVersion > 1 && oldVersion <= 1) {
      String sql = 'ALTER TABLE t_banner ADD content TEXT DEFAULT ""';
      Batch batch = db.batch();
      batch.execute(sql);
      await batch.commit();
      Log.d('Database onUpgrade_1_2: $sql', tag: _TAG);
    }
  }

  Future<void> _onUpgrade_2_3(Database db, int oldVersion, int newVersion) async {
    if (newVersion > 2 && oldVersion <= 2) {
      String sql = 'ALTER TABLE t_banner ADD flutter TEXT DEFAULT ""';
      Batch batch = db.batch();
      batch.execute(sql);
      await batch.commit();
      Log.d('Database onUpgrade_2_3: $sql', tag: _TAG);
    }
  }

  /// 删除数据库
  Future<void> delete() async => await getPath().then((value) async => await deleteDatabase(value).then((value) => Log.d('删除数据库成功', tag: _TAG)));

  /// 关闭数据库
  Future<void> close() async {
    // 如果数据库存在，而且数据库没有关闭，先关闭数据库
    if (_database != null && _database!.isOpen) {
      await _database!.close().then((value) => _database = null);
    }
  }

  /// 获取数据库名称
  String getDBName() {
    return "db_${SpUtil.getUserId()}.db";
  }

  /// 获取数据库的路径
  Future<String> getPath() async {
    String databasesPath = await getDatabasesPath();
    String dbName = getDBName();
    Log.d('数据库路径=$databasesPath, 数据库名称=$dbName', tag: _TAG);
    return join(databasesPath, dbName);
  }

  /// 判断表是否存在
  Future<bool> isTableExist(String tableName) async {
    Database db = await open();
    List list = await db.rawQuery("SELECT * FROM Sqlite_master WHERE TYPE = 'table' AND NAME = '$tableName'");
    return list.length > 0;
  }

  /// 创建新表
  Future<void> _createTable(Database db, String tableName, String columnString) async {
    String sql = 'CREATE TABLE IF NOT EXISTS $tableName ($columnString)';
    await db.execute(sql).then((value) => Log.d('创建$tableName表: $sql'));
  }

  /// 如果表不存在，进行创建表
  Future<void> checkTable(Database db, BaseDB data) async {
    String tableName = data.getTableName();
    bool isTableExist = await SqlManager().isTableExist(tableName);
    if (!isTableExist) {
      String columnString = data.columnString();
      await _createTable(db, tableName, columnString);
    }
  }

  // 插入数据
  Future<int> insertItem<T extends BaseDB>(
    T data, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    Database db = await open();
    await checkTable(db, data);
    String tableName = data.getTableName();

    int id = 0;
    id = await db.insert(
      tableName,
      data.toJson(),
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
    );
    Log.d('表$tableName新增 id=$id 数据: ${data.toJson()}', tag: _TAG);
    return id;
  }

  /// 删除数据，当key和value存在时，删除对应表中的数据，当key和value不存在时，删除该表
  Future<int> deleteItem<T extends BaseDB>(
    T data, {
    String? key,
    String? value,
  }) async {
    Database db = await open();
    await checkTable(db, data);
    String tableName = data.getTableName();

    key = key ?? '';
    value = value ?? '';
    int count = 0;
    if (key.isEmpty || value.isEmpty) {
      count = await db.delete(tableName);
    } else {
      count = await db.delete(
        tableName,
        where: '$key = ?',
        whereArgs: [value],
      );
      Log.d('表$tableName删除 key=$key, value=$value 数据$count条', tag: _TAG);
    }
    return count;
  }

  /// 更新数据，更新对应key和value表中的数据
  Future<int> updateItem<T extends BaseDB>(
    T data,
    String key,
    String value, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    Database db = await open();
    await checkTable(db, data);
    String tableName = data.getTableName();

    int count = 0;
    // 更新数据
    count = await db.update(
      tableName,
      data.toJson(),
      where: '$key = ?',
      whereArgs: [value],
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
    );
    Log.d('表$tableName更新 key=$key, value=$value 数据$count条', tag: _TAG);
    return count;
  }

  // 查询数据，当key和value存在时，查询对应表中的数据，当key和value不存在时，查询对应表中所有数据
  Future<List<BaseDB>> queryItem<T extends BaseDB>(
    T data, {
    Map<String, String>? where,
  }) async {
    Database db = await open();
    await checkTable(db, data);
    String tableName = data.getTableName();

    List<Map<String, dynamic>> list = [];

    if (where != null) {
      StringBuffer queryParams = StringBuffer();
      StringBuffer wheres = StringBuffer();
      List whereArgs = [];
      where.forEach((key, value) {
        if (wheres.isNotEmpty) wheres.write(',');
        wheres.write('$key = ?');
        whereArgs.add(value);
        queryParams.write('key=$key, value=$value');
      });

      list = await db.query(
        tableName,
        where: wheres.toString(),
        whereArgs: whereArgs,
      );
      Log.d('表$tableName查询 ${queryParams.toString()} 数据${list.length}条: $list', tag: _TAG);
    } else {
      list = await db.query(tableName);
      Log.d('表$tableName查询数据 ${list.length} 条: $list', tag: _TAG);
    }

    // map转换为List集合
    return List.generate(list.length, (i) => data.fromJson(list[i]));
  }
}
