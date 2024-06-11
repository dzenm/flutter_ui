import 'db_manager.dart';

class Sql {
  //// 数据库版本
  static const dbVersion = 1;

  /// 常用数据库语句，使用以下语句记得需要跟其他字符串中间加空格，否则执行时会识别为错误
  static const String createTable = 'CREATE TABLE IF NOT EXISTS';
  static const String pragmaTable = 'PRAGMA table_info';
  static const String dropTable = 'DROP TABLE IF EXISTS';
  static const String selectTable = "SELECT * FROM sqlite_master WHERE TYPE='table'";

  /// 更新数据库的语句
  static const List<UpgradeDatabase?> upgrades = [
    _onUpgrade_1_2,
    _onUpgrade_2_3,
    _onUpgrade_3_4,
    _onUpgrade_4_5,
  ];

  ///============================== 0 创建表SQL ================================

  static const String _createWebsiteTable = '''$createTable t_website(
    id INTEGER PRIMARY KEY NOT NULL, 
    category TEXT, 
    icon TEXT, 
    link TEXT, 
    name TEXT, 
    "order" INTEGER, 
    visible INTEGER
  );''';

  static const String _createSystemTable = '''$createTable t_system(
    id INTEGER PRIMARY KEY NOT NULL, 
    admin BIT, 
    password TEXT, 
    isDelete INTEGER
  );''';

  ///============================== 1 升级数据库 ===============================
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
  //
  // – 添加UNIQUE(唯一索引)
  // – ALTER TABLE t_test ADD UNIQUE (e);
  //
  // – 添加INDEX(普通索引)
  // – ALTER TABLE t_test ADD INDEX index_name ( e );
  //
  // – 添加FULLTEXT(全文索引)
  // – ALTER TABLE t_test ADD FULLTEXT (e);
  //
  // – 添加多列索引
  // – ALTER TABLE t_test ADD INDEX index_name ( a, b, c )

  /// 数据库版本1升级到版本2
  static List<String> _onUpgrade_1_2(int oldVersion, int newVersion) {
    List<String> list = [];
    if (oldVersion <= 1 && newVersion > 1) {
      list.add('ALTER TABLE t_user ADD uuid TEXT DEFAULT ""');
      list.add('ALTER TABLE t_user ADD account TEXT DEFAULT ""');
      log('Database onUpgrade_1_2: ');
      for (var sql in list) {
        log('    $sql', blank: true);
      }
    }
    return list;
  }

  /// 数据库版本2升级到版本3
  static List<String> _onUpgrade_2_3(int oldVersion, int newVersion) {
    List<String> list = [];
    if (oldVersion <= 2 && newVersion > 2) {
      list.add(_createSystemTable);
      log('Database onUpgrade_2_3: ');
      for (var sql in list) {
        log('    $sql', blank: true);
      }
    }
    return list;
  }

  /// 数据库版本3升级到版本4
  static List<String> _onUpgrade_3_4(int oldVersion, int newVersion) {
    List<String> list = [];
    if (oldVersion <= 3 && newVersion > 3) {
      list.add('ALTER TABLE t_system ADD title TEXT DEFAULT ""');
      list.add('ALTER TABLE t_system ADD content TEXT DEFAULT ""');
      list.add('ALTER TABLE t_system ADD footer TEXT DEFAULT ""');
      log('Database onUpgrade_3_4: ');
      for (var sql in list) {
        log('    $sql', blank: true);
      }
    }
    return list;
  }

  /// 数据库版本4升级到版本5
  static List<String> _onUpgrade_4_5(int oldVersion, int newVersion) {
    List<String> list = [];
    if (oldVersion <= 4 && newVersion > 4) {
      list.add(_createWebsiteTable);
      log('Database onUpgrade_3_4: ');
      for (var sql in list) {
        log('    $sql', blank: true);
      }
    }
    return list;
  }

  static void log(dynamic message, {bool blank = false}) {
    if (blank) {
      message = message.toString().replaceAll('\n', '    \n');
    }
    DBManager().log(message);
  }
}
