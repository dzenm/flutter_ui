import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'column_entity.dart';
import 'db_base_entity.dart';
import 'db_manager.dart';
import 'db_sql.dart';
import 'table_entity.dart';

/// 临时表后缀
const _tempSuffix = '_TEMP';

///
/// Created by a0010 on 2023/9/28 11:13
///
class DBManagerDelegate {
  DBManagerDelegate();

  Database? _database;

  /// 当前打开的数据库名称
  String? _currentDBName;

  /// 当前打开的数据库路径
  String? _dbPath;

  /// 数据库名称，根据用户信息设置，如果不设置，默认使用userId
  String _userId = 'userId';

  set userId(String userId) {
    _userId = userId;
  }

  /// 日志打印，如果不设置，将不打印日志，如果要设置在使用数据库之前调用 [init]
  Function? _logPrint;

  /// 注册的所有数据表
  final List<DBBaseEntity> _tables = [];

  List<DBBaseEntity> get tables => _tables;

  void init({Function? logPrint, List<DBBaseEntity>? tables}) {
    _logPrint = logPrint;
    if (tables != null) {
      _tables.addAll(tables);
    }
  }

  /// 获取当前数据库对象, 未指定数据库名称时默认为用户名 [_userId]，切换数据库操作时要先关闭 [close] 再重新打开。
  Future<Database?> getDatabase({String? dbName}) async {
    if (_database == null || _currentDBName != dbName) {
      String path = await getPath(dbName: dbName);
      if (Platform.isWindows || Platform.isLinux) {
        // Windows端初始化数据库
        sqfliteFfiInit();
        // 获取databaseFactoryFfi对象
        var databaseFactory = databaseFactoryFfi;
        _database = await databaseFactory.openDatabase(path,
            options: OpenDatabaseOptions(
              version: Sql.dbVersion,
              onCreate: _onCreate,
              onUpgrade: _onUpgrade,
            ));
      } else {
        _database = await openDatabase(
          path,
          version: Sql.dbVersion,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
        );
      }
      _currentDBName = dbName;
    }
    return _database!;
  }

  /// 当数据库不存在时调用并进行创建, 只在创建第一次时调用
  void _onCreate(Database db, int version) async {
    log('创建数据库：initVersion=$version');

    // 创建数据表
    for (var table in _tables) {
      await _createTable(db, sql: '${Sql.createTable} ${table.createTableSql}');
    }
  }

  /// 当数据库版本变化时调用并进行升级，所有数据库变动均需通过代码更新
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    log('升级数据库：oldVersion=$oldVersion, newVersion=$newVersion');

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

  /// 生成临时表，将原表数据进行迁移
  Future<void> _generateTempTables(String tableName, {String? dbName}) async {
    Database? db = await getDatabase(dbName: dbName);
    if (db == null) return;
    bool existTable = await isTableExist(tableName);
    if (!existTable) {
      DBBaseEntity? table = _getTable(tableName);
      if (table != null) {
        await db.execute('${Sql.createTable} ${table.createTableSql}');
      }
    }
    String tempTableName = '$tableName$_tempSuffix';
    String sql = 'CREATE TEMP TABLE $tempTableName AS SELECT * FROM $tableName;';
    await db.execute(sql);
    log('创建临时表：tempTableName=$tempTableName, sql=$sql');
  }

  /// 删除表
  Future<void> _dropTableString(String tableName, {String? dbName}) async {
    Database? db = await getDatabase(dbName: dbName);
    if (db == null) return;
    await db.execute('${Sql.dropTable} $tableName;');
  }

  /// 创建新表，将临时表数据进行迁移至新表
  Future<void> _restoreData(String tableName, List<String> newColumns, {String? dbName}) async {
    Database? db = await getDatabase(dbName: dbName);
    if (db == null) return;
    String tempTableName = '$tableName$_tempSuffix';
    var result = await db.rawQuery('SELECT * FROM $tempTableName limit 1', null);
    // 表数据不为空，进行数据表的迁移
    if (result.isNotEmpty) {
      // 获取原数据表(临时表)的列名
      List<String> oldColumns = result.first.keys.toList();
      // 判断新旧表是否存在字段的增删
      List<String> diffProperties = [];
      for (var property in newColumns) {
        if (!oldColumns.contains(property)) continue;
        diffProperties.add(property);
      }
      log('新旧数据表的差异: diffProperties=$diffProperties');
      if (diffProperties.isNotEmpty) {
        final String columnSQL = _combineColumn(diffProperties);
        String sql = 'INSERT INTO $tableName ($columnSQL) SELECT $columnSQL FROM $tempTableName;';
        await db.execute(sql);
        log('临时表数据迁移至新数据表: tableName=$tableName, sql=$sql');
      }
    }
    // 删除临时表
    await db.execute('${Sql.dropTable} $tempTableName');
  }

  /// 根据表名获取对应的实体类
  DBBaseEntity? _getTable(String tableName) {
    for (var table in _tables) {
      if (table.tableName == tableName) return table;
    }
    return null;
  }

  /// 合并列名
  String _combineColumn(List<String> columns) {
    String sql = '';
    for (var element in columns) {
      sql += '$element,';
    }
    return sql.isEmpty ? sql : sql.substring(0, sql.length - 1);
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
      log('初始化数据库信息：path=$path, dbName=$dbName');
      _dbPath = join(path, dbName);
    }
    return _dbPath!;
  }

  /// 获取数据库所在的路径
  /// Android：/data/user/0/<package_name>/app_flutter/<userId>/Databases
  /// iOS：/Users/a0010/Library/Containers/<package_name>/Data/<userId>/Databases
  /// macOS：/Users/a0010/Documents/FlutterUI/userId>/Databases
  /// Windows：C:\Users\Administrator\Documents\FlutterUI\<userId>\Databases
  Future<String> get databasesPath async {
    String rootDir = 'FlutterUI';
    String dirName = 'Databases';
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String dbDir = join(appDocDir.path);
    if (Platform.isAndroid) {
      dbDir = join(appDocDir.path, _userId, dirName);
    }
    if (Platform.isIOS) {
      dbDir = join(appDocDir.path, _userId, dirName);
    }
    if (Platform.isMacOS) {
      dbDir = join(appDocDir.path, rootDir, _userId, dirName);
    }
    if (Platform.isWindows) {
      dbDir = join(appDocDir.path, rootDir, _userId, dirName);
    }
    if (Platform.isLinux) {
      dbDir = join(appDocDir.path, rootDir, _userId, dirName);
    }
    Directory result = Directory(dbDir);
    if (!result.existsSync()) {
      result.createSync(recursive: true);
    }
    return dbDir;
  }

  /// 判断表是否存在
  Future<bool> isTableExist(String tableName, {String? dbName}) async {
    Database? db = await getDatabase(dbName: dbName);
    if (db == null) return false;
    List list = await db.rawQuery("${Sql.selectTable} AND NAME='$tableName'");
    return list.isNotEmpty;
  }

  /// 如果表不存在，进行创建表
  Future<void> checkTable(String tableName, String columnString, {String? dbName}) async {
    bool existTable = await isTableExist(tableName);
    if (existTable) return;
    await _createTable(_database!, tableName: tableName, columnString: columnString);
  }

  /// 创建新表, 参数[tableName] 和 [columnString] 通过拼接一起使用, 参数[sql]通过自定义创建新表。
  Future<void> _createTable(Database db, {String? tableName, String? columnString, String? sql}) async {
    String sqlString = sql ?? '${Sql.createTable} $tableName ($columnString)';
    try {
      await db.execute(sqlString).then((value) => log('创建${tableName ?? '新'}表: $sqlString'));
    } catch (err) {
      log('创建${tableName ?? '新'}表失败：err=$err');
    }
  }

  /// 获取数据中所有表的数据
  Future<List<TableEntity>> getTables({String? dbName}) async {
    Database? db = await getDatabase(dbName: dbName);
    if (db == null) return [];
    List<dynamic> list = await db.rawQuery(Sql.selectTable);
    log('查询所有表: $list');
    return list.map((table) => TableEntity.fromJson(table)).toList();
  }

  /// 获取数据库中表的所有列结构的数据
  Future<List<ColumnEntity>> getTableColumns(String dbName, String tableName) async {
    Database? db = await getDatabase(dbName: dbName);
    if (db == null) return [];
    List list = await db.rawQuery('${Sql.pragmaTable} ($tableName)');
    log('查询表列名: $list');
    return list.map((column) => ColumnEntity.fromJson(column)).toList();
  }

  /// 插入数据
  Future<int> insert(
    String tableName,
    Map<String, dynamic> values, {
    String? dbName,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    Database? db = await getDatabase(dbName: dbName);
    int id = -1;
    if (db == null) return id;
    id = await db.insert(
      tableName,
      values,
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
    );
    log('表$tableName新增数据 id=$id, data=$values ');
    return id;
  }

  /// 删除数据
  Future<int> delete(
    String tableName, {
    String? dbName,
    String? where,
    List<Object?>? whereArgs,
  }) async {
    Database? db = await getDatabase(dbName: dbName);
    int count = 0;
    if (db == null) return count;

    count = await db.delete(
      tableName,
      where: where,
      whereArgs: whereArgs,
    );
    log('表`$tableName`${_mergeSql(where, whereArgs)}条件共删除数据$count条');
    return count;
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
    Database? db = await getDatabase(dbName: dbName);
    if (db == null) return -1;

    int count = 0;
    // 更新数据
    count = await db.update(
      tableName,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.replace,
    );
    log('表`$tableName`${_mergeSql(where, whereArgs)}条件共更新数据$count条');
    return count;
  }

  /// 更新数据
  Future<int> rawUpdate(
    String sql,
    List<Object?>? args, {
    String? dbName,
  }) async {
    Database? db = await getDatabase(dbName: dbName);
    if (db == null) return -1;

    int count = 0;
    // 更新数据
    count = await db.rawUpdate(sql, args);
    log('根据${_mergeSql(sql, args)}条件共更新数据$count条');
    return count;
  }

  /// 查询数据，使用sql查询
  Future<List<Map<String, dynamic>>> query<T extends DBBaseEntity>(
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
    Database? db = await getDatabase(dbName: dbName);
    if (db == null) return [];

    List<Map<String, dynamic>> list = await db.query(
      tableName,
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
    log('表`$tableName`${_mergeSql(where, whereArgs)}条件共查询数据${list.length}条, data=$list');
    return list;
  }

  /// 获取运行时的表类型
  T? _getRuntimeTypeTable<T extends DBBaseEntity>() {
    for (var tab in tables) {
      if (tab is! T) continue;
      return tab;
    }
    return null;
  }

  void _handleMap(
    Map<String, dynamic>? whereMap,
    List<String> whereArgs,
    StringBuffer where,
    StringBuffer params,
  ) {
    whereMap?.forEach((key, value) {
      if (where.isNotEmpty) where.write(',');
      where.write('$key = ?');
      whereArgs.add(value);
      params.write('$key=$value');
    });
  }

  /// 将查询语句和对应的值合并为完整的sql
  String _mergeSql(String? where, List<Object?>? args) {
    if ((where ?? '').isEmpty) return '';
    if ((args ?? []).isEmpty) return '符合`$where`';

    StringBuffer sb = StringBuffer();
    for (int i = 0, j = 0; i < where!.length; i++) {
      if (where[i] == '?') {
        sb.write(args![j++]);
        continue;
      }
      sb.write(where[i]);
    }
    return '符合`${sb.toString()}`';
  }

  void log(String text) => _logPrint == null ? null : _logPrint!(text, tag: 'DBManager');
}
