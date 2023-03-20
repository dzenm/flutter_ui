import 'db_manager.dart';

class Sql {
  /// 数据库版本
  static const dbVersion = 5;

  /// 常用数据库语句
  static const String createTable = 'CREATE TABLE IF NOT EXISTS';
  static const String pragmaTable = 'PRAGMA table_info';
  static const String selectAllTable = "SELECT * FROM sqlite_master WHERE TYPE='table'";

  /// 创建数据表的语句
  static const List<String> createTables = [
    createUserTable,
    createBannerTable,
    createArticleTable,
    createWebsiteTable,
  ];

  /// 更新数据库的语句
  static const List<UpgradeDatabase> upgrades = [
    _onUpgrade_1_2,
    _onUpgrade_2_3,
    _onUpgrade_3_4,
    _onUpgrade_4_5,
  ];

  ///============================== 0 创建表SQL ================================

  static const String createUserTable = '''$createTable t_user(
    id INTEGER PRIMARY KEY NOT NULL, 
    admin BIT, 
    chapterTops TEXT, 
    coinCount INTEGER, 
    collectIds TEXT, 
    email TEXT, 
    icon TEXT, 
    nickname TEXT, 
    password TEXT, 
    publicName TEXT, 
    token TEXT, 
    type INTEGER, 
    username TEXT
  );''';

  static const String createBannerTable = '''$createTable t_banner(
    id INTEGER PRIMARY KEY NOT NULL, 
    "desc" TEXT, 
    imagePath TEXT, 
    isVisible INTEGER, 
    "order" INTEGER, 
    title TEXT, 
    type INTEGER, 
    url TEXT
  );''';

  static const String createArticleTable = '''$createTable t_article(
    id INTEGER PRIMARY KEY NOT NULL, 
    adminAdd BIT,
    apkLink TEXT,
    audit INTEGER,
    author TEXT,
    canEdit BIT,
    chapterId INTEGER,
    chapterName TEXT,
    collect BIT,
    courseId INTEGER,
    "desc" TEXT,
    descMd TEXT,
    envelopePic TEXT,
    fresh BIT,
    host TEXT,
    isAdminAdd BIT,
    link TEXT,
    niceDate TEXT,
    niceShareDate TEXT,
    origin TEXT,
    prefix TEXT,
    projectLink TEXT,
    publishTime INTEGER,
    realSuperChapterId INTEGER,
    route BIT,
    selfVisible INTEGER,
    shareDate INTEGER,
    shareUser TEXT,
    superChapterId INTEGER,
    superChapterName TEXT,
    title TEXT,
    tags TEXT,
    type INTEGER,
    userId INTEGER,
    visible INTEGER,
    zan INTEGER
  );''';

  static const String createWebsiteTable = '''$createTable t_website(
    id INTEGER PRIMARY KEY NOT NULL, 
    category TEXT, 
    icon TEXT, 
    link TEXT, 
    name TEXT, 
    "order" INTEGER, 
    visible INTEGER
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

  // 数据库版本1升级到版本2
  static String? _onUpgrade_1_2(int oldVersion, int newVersion) {
    if (newVersion > 1 && oldVersion <= 1) {
      DBManager.instance.log('Database onUpgrade_1_2: $createUserTable');
      return createUserTable;
    }
    return null;
  }

  // 数据库版本2升级到版本3
  static String? _onUpgrade_2_3(int oldVersion, int newVersion) {
    if (newVersion > 2 && oldVersion <= 2) {
      String sql = 'ALTER TABLE t_banner ADD flutter TEXT DEFAULT ""';
      DBManager.instance.log('Database onUpgrade_2_3: $sql');
      return sql;
    }
    return null;
  }

  // 数据库版本3升级到版本4
  static String? _onUpgrade_3_4(int oldVersion, int newVersion) {
    if (newVersion > 3 && oldVersion <= 4) {
      String sql = 'ALTER TABLE t_banner ADD content TEXT DEFAULT ""';
      DBManager.instance.log('Database onUpgrade_3_4: $sql');
      return sql;
    }
    return null;
  }

  // 数据库版本4升级到版本5
  static String? _onUpgrade_4_5(int oldVersion, int newVersion) {
    if (newVersion > 4 && oldVersion <= 5) {
      String sql = createWebsiteTable;
      DBManager.instance.log('Database onUpgrade_4_5: $sql');
      return sql;
    }
    return null;
  }
}
