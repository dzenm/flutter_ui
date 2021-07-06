class Sql {
  static const String tableBannerSql = '''
  
        CREATE TABLE IF NOT EXISTS t_banner(
          id INTEGER PRIMARY KEY NOT NULL, 
          "desc" TEXT, 
          imagePath TEXT, 
          isVisible INTEGER, 
          "order" INTEGER, 
          title TEXT, 
          type INTEGER, 
          url TEXT
        );''';

  static const String tableArticleSql = '''
  
        CREATE TABLE IF NOT EXISTS t_article(
          id INTEGER PRIMARY KEY NOT NULL, 
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
          link TEXT,
          niceDate TEXT,
          niceShareDate TEXT,
          origin TEXT,
          prefix TEXT,
          projectLink TEXT,
          publishTime INTEGER,
          realSuperChapterId INTEGER,
          selfVisible INTEGER,
          shareDate INTEGER,
          shareUser TEXT,
          superChapterId INTEGER,
          superChapterName TEXT,
          title TEXT,
          type INTEGER,
          userId INTEGER,
          visible INTEGER,
          zan INTEGER
        );''';
}
