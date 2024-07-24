import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'package:fbl/fbl.dart';
import 'converts/bool_convert.dart';

part 'article_entity.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 文章
@JsonSerializable(explicitToJson: true)
class ArticleEntity extends DBBaseEntity {
  @BoolConvert()
  bool? adminAdd;
  String? apkLink;
  int? audit;
  String? author;
  @BoolConvert()
  bool? canEdit;
  int? chapterId;
  String? chapterName;
  @BoolConvert()
  bool? collect;
  int? courseId;
  String? desc;
  String? descMd;
  String? envelopePic;
  @BoolConvert()
  bool? fresh;
  String? host;
  int? id;
  @BoolConvert()
  bool? isAdminAdd;
  String? link;
  String? niceDate;
  String? niceShareDate;
  String? origin;
  String? prefix;
  String? projectLink;
  int? publishTime;
  int? realSuperChapterId;
  @BoolConvert()
  bool? route;
  int? selfVisible;
  int? shareDate;
  String? shareUser;
  int? superChapterId;
  String? superChapterName;
  String? title;
  @TagsConvert()
  List<TagEntity> tags = [];
  int? type;
  int? userId;
  int? visible;
  int? zan;

  ArticleEntity() : super();

  factory ArticleEntity.fromJson(Map<String, dynamic> json) => _$ArticleEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArticleEntityToJson(this);

  @override
  String get createTableSql => '''$tableName(
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

  Future<List<ArticleEntity>> query() async {
    List<dynamic> list = await DBManager().query(tableName);
    return list.map((e) => ArticleEntity.fromJson(e)).toList();
  }

  Future<int> insert(ArticleEntity article) async {
    return await DBManager().insert(tableName, article.toJson());
  }

  Future<int> update(ArticleEntity article) async {
    return await DBManager().update(tableName, article.toJson(), where: 'id = ?', whereArgs: [article.id]);
  }

  Future<int> delete(int id) async {
    return await DBManager().delete(tableName, where: 'id = ?', whereArgs: [id]);
  }
}

/// 标签
@JsonSerializable()
class TagEntity extends DBBaseEntity {
  String? name;
  String? url;

  TagEntity() : super();

  @override
  factory TagEntity.fromJson(Map<String, dynamic> json) => _$TagEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TagEntityToJson(this);
}

/// 标签数据转换器
class TagsConvert implements JsonConverter<List<TagEntity>, dynamic> {
  const TagsConvert();

  @override
  List<TagEntity> fromJson(dynamic json) {
    List<dynamic> list = [];
    if (json is List) {
      list = json;
    } else if (json is String) {
      list = jsonDecode(json) as List<dynamic>;
    }
    return list.map((e) => TagEntity.fromJson(e)).toList();
  }

  @override
  dynamic toJson(List<TagEntity> object) {
    try {
      return jsonEncode(object.map((e) => e.toJson()).toList());
    } catch (e) {
      return jsonEncode(object);
    }
  }
}
