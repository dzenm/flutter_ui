import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';

import 'dp_manager.dart';

abstract class DbImpl {
  bool isTableExits = false;

  createTable();

  tableName();

  dropTable();

  ///创建表sql语句
  tableBaseString(String tableName, String columnId) => '''create table if not exists $tableName ($columnId text primary key not null,''';

  generateTempTables(Database db, String name) async {
//    if (!isTableExits) {
//      await prepare(tableName(), createTableString());
//    }
    if (!isTableExits) {
      await db.execute(createTable());
    }
    String tempTableName = '${name}_TEMP';
    String sql = 'CREATE TEMP TABLE $tempTableName AS SELECT * FROM $name;';
    await db.execute(sql);
    print('dbManager temp $tempTableName $sql');
  }

  dropTableString(Database db, String name) async {
    await db.execute('DROP TABLE IF EXISTS $name;');
  }

  restoreData(Database db, String name, List<String> currentProperties) async {
    String tempTableName = '${name}_TEMP';
    // get all columns from tempTable, take careful to use the columns list
    var result = await db.rawQuery('SELECT * FROM $tempTableName limit 1', null);
    if (result.length > 0) {
      List<String> columns = result.first.keys.toList();
      print('dbManager tmp ${columns.length} $columns');
      List<String> property = [];
      print('dbManager current ${currentProperties.length} $currentProperties');
      currentProperties.forEach((element) {
        if (columns.contains(element)) {
          property.add(element);
        }
      });
      print('dbManager property ${property.length} $property');
      if (property.length > 0) {
        final String columnSQL = '';

        String sql = 'INSERT INTO $name ($columnSQL) SELECT $columnSQL FROM $tempTableName;';
        await db.execute(sql);

        print('dbManager restore $tempTableName $sql');
      }
    }
    await db.execute('DROP TABLE $tempTableName');
  }

  Future<Database> getDataBase() async {
    return await open();
  }

  ///super 函数对父类进行初始化
  @mustCallSuper
  prepare(name, String createSql) async {
    isTableExits = await SqlManager.isTableExits(name);
    if (!isTableExits) {
      Database? db = await SqlManager.getCurrentDatabase();
      return await db!.execute(createSql);
    }
  }

  @mustCallSuper
  open() async {
    if (!isTableExits) {
      await prepare(tableName(), createTable());
    }
    return await SqlManager.getCurrentDatabase();
  }
}
