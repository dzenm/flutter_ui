import 'package:json_annotation/json_annotation.dart';

import '../base/db/db.dart';
import 'article_entity.dart';
import 'converts/bool_convert.dart';

part 'tree_entity.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 体系
@JsonSerializable(explicitToJson: true)
class TreeEntity extends DBBaseEntity {
  List<ArticleEntity> articleList = [];
  String? author;
  List<TreeEntity> children = [];
  int? courseId;
  int? id;
  String? cover;
  String? desc;
  String? lisense;
  String? lisenseLink;
  String? name;
  int? order;
  int? parentChapterId;
  int? type;
  @BoolConvert()
  bool? userControlSetTop;
  int? visible;

  TreeEntity();

  factory TreeEntity.fromJson(Map<String, dynamic> json) => _$TreeEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TreeEntityToJson(this);

  @override
  DBBaseEntity fromJson(Map<String, dynamic> json) => _$TreeEntityFromJson(json);

  @override
  Map<String, String> get primaryKey => {'id': '$id'};
}
