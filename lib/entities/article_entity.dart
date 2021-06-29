import 'package:flutter_ui/base/db/db_model.dart';

class ArticleEntity extends BaseDB {
  String? apkLink;
  int? audit;
  String? author;
  bool? canEdit;
  int? chapterId;
  String? chapterName;
  bool? collect;
  int? courseId;
  String? desc;
  String? descMd;
  String? envelopePic;
  bool? fresh;
  String? host;
  int? id;
  String? link;
  String? niceDate;
  String? niceShareDate;
  String? origin;
  String? prefix;
  String? projectLink;
  int? publishTime;
  int? realSuperChapterId;
  int? selfVisible;
  int? shareDate;
  String? shareUser;
  int? superChapterId;
  String? superChapterName;
  String? title;
  int? type;
  int? userId;
  int? visible;
  int? zan;

  ArticleEntity() : super();

  @override
  ArticleEntity.fromJson(Map<String, dynamic> json) {
    apkLink = json['apkLink'];
    audit = json['audit'];
    canEdit = json['canEdit'] == 1;
    chapterId = json['chapterId'];
    chapterName = json['chapterName'];
    collect = json['collect'] == 1;
    courseId = json['courseId'];
    desc = json['desc'];
    descMd = json['descMd'];
    envelopePic = json['envelopePic'];
    fresh = json['fresh'] == 1;
    host = json['host'];
    id = json['id'];
    link = json['link'];
    niceDate = json['niceDate'];
    niceShareDate = json['niceShareDate'];
    origin = json['origin'];
    prefix = json['prefix'];
    projectLink = json['projectLink'];
    publishTime = json['publishTime'];
    realSuperChapterId = json['realSuperChapterId'];
    selfVisible = json['selfVisible'];
    shareDate = json['shareDate'];
    shareUser = json['shareUser'];
    superChapterId = json['superChapterId'];
    superChapterName = json['superChapterName'];
    title = json['title'];
    type = json['type'];
    userId = json['userId'];
    visible = json['visible'];
    zan = json['zan'];
  }

  @override
  Map<String, dynamic> toJson() => {
        'apkLink': apkLink,
        'audit': audit,
        'canEdit': canEdit,
        'chapterId': chapterId,
        'chapterName': chapterName,
        'collect': collect,
        'courseId': courseId,
        'desc': desc,
        'descMd': descMd,
        'envelopePic': envelopePic,
        'fresh': fresh,
        'host': host,
        'id': id,
        'link': link,
        'niceDate': niceDate,
        'niceShareDate': niceShareDate,
        'origin': origin,
        'prefix': prefix,
        'projectLink': projectLink,
        'publishTime': publishTime,
        'realSuperChapterId': realSuperChapterId,
        'selfVisible': selfVisible,
        'shareDate': shareDate,
        'shareUser': shareUser,
        'superChapterId': superChapterId,
        'superChapterName': superChapterName,
        'title': title,
        'type': type,
        'userId': userId,
        'visible': visible,
        'zan': zan,
      };

  @override
  ArticleEntity fromJson(Map<String, dynamic> json) => ArticleEntity.fromJson(json);

  @override
  String columnString() => '''
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
    zan INTEGER''';

  @override
  String getTableName() => 't_article';
}
