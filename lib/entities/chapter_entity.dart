import 'package:flutter_ui/entities/article_entity.dart';
import 'package:json_annotation/json_annotation.dart';

import '../base/db/db.dart';

part 'chapter_entity.g.dart';

///
/// Created by a0010 on 2023/8/9 15:43
///
/// 公众号/教程实体类
@JsonSerializable()
class ChapterEntity extends DBBaseEntity {
  List<ArticleEntity>? articleList;
  String? author;
  List children = [];
  int? courseId;
  String? cover;
  String? desc;
  int? id;
  String? lisense;
  String? lisenseLink;
  String? name;
  int? order;
  int? parentChapterId;
  int? type;
  bool? userControlSetTop;
  int? visible;

  ChapterEntity() : super();

  factory ChapterEntity.fromJson(Map<String, dynamic> json) => _$ChapterEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ChapterEntityToJson(this);

  @override
  ChapterEntity fromJson(Map<String, dynamic> json) => _$ChapterEntityFromJson(json);

  @override
  Map<String, String> get primaryKey => {'id': '$id'};
}
