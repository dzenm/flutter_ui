import 'package:flutter_ui/base/db/db_base_model.dart';
import 'package:json_annotation/json_annotation.dart';
part 'collect_entity.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 收藏
@JsonSerializable()
class CollectEntity extends DBBaseModel {
  String? author;
  int? chapterId;
  String? chapterName;
  int? courseId;
  String? desc;
  String? envelopePic;
  int? id;
  String? link;
  String? niceDate;
  String? origin;
  int? originId;
  int? publishTime;
  String? title;
  int? userId;
  int? visible;
  int? zan;

  CollectEntity();

  @override
  factory CollectEntity.fromJson(Map<String, dynamic> json) => _$CollectEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CollectEntityToJson(this);

  @override
  DBBaseModel fromJson(Map<String, dynamic> json) => fromJson(json);

  @override
  String get primaryKey => 'id';

  @override
  String get primaryValue => '$id';
}
