import 'package:flutter_ui/base/db/db_base_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'article_entity.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 文章
@JsonSerializable()
class ArticleEntity extends DBBaseModel {
  bool? adminAdd;
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
  bool? isAdminAdd;
  String? link;
  String? niceDate;
  String? niceShareDate;
  String? origin;
  String? prefix;
  String? projectLink;
  int? publishTime;
  int? realSuperChapterId;
  bool? route;
  int? selfVisible;
  int? shareDate;
  String? shareUser;
  int? superChapterId;
  String? superChapterName;
  String? title;
  List<TagEntity> tags = [];
  int? type;
  int? userId;
  int? visible;
  int? zan;

  ArticleEntity() : super();

  @override
  factory ArticleEntity.fromJson(Map<String, dynamic> json) => _$ArticleEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ArticleEntityToJson(this);

  @override
  DBBaseModel fromJson(Map<String, dynamic> json) => fromJson(json);

  @override
  String get primaryKey => 'id';

  @override
  String get primaryValue => '$id';
}

@JsonSerializable()
class TagEntity extends DBBaseModel {
  String? name;
  String? url;

  TagEntity() : super();

  @override
  factory TagEntity.fromJson(Map<String, dynamic> json) => _$TagEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TagEntityToJson(this);

  @override
  DBBaseModel fromJson(Map<String, dynamic> json) => fromJson(json);

  @override
  String get primaryKey => 'name';

  @override
  String get primaryValue => '$name';
}
