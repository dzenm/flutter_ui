import 'package:flutter_ui/base/db/db_base_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'article_entity.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 文章
@JsonSerializable(explicitToJson: true)
class ArticleEntity extends DBBaseModel {
  @JsonKey(toJson: toBool, fromJson: boolToInt)
  bool? adminAdd;
  String? apkLink;
  int? audit;
  String? author;
  @JsonKey(toJson: toBool, fromJson: boolToInt)
  bool? canEdit;
  int? chapterId;
  String? chapterName;
  @JsonKey(toJson: toBool, fromJson: boolToInt)
  bool? collect;
  int? courseId;
  String? desc;
  String? descMd;
  String? envelopePic;
  @JsonKey(toJson: toBool, fromJson: boolToInt)
  bool? fresh;
  String? host;
  int? id;
  @JsonKey(toJson: toBool, fromJson: boolToInt)
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
  ArticleEntity fromJson(Map<String, dynamic> json) => ArticleEntity.fromJson(json);

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
  TagEntity fromJson(Map<String, dynamic> json) => TagEntity.fromJson(json);

  @override
  String get primaryKey => 'name';

  @override
  String get primaryValue => '$name';
}
