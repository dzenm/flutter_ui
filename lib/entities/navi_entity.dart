import 'package:flutter_ui/base/db/db_base_model.dart';
import 'package:flutter_ui/entities/article_entity.dart';
import 'package:json_annotation/json_annotation.dart';
part 'navi_entity.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 导航
@JsonSerializable()
class NaviEntity extends DBBaseModel {
  List<ArticleEntity> articles = [];
  String? name;
  int? cid;

  NaviEntity();

  @override
  factory NaviEntity.fromJson(Map<String, dynamic> json) => _$NaviEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NaviEntityToJson(this);

  @override
  DBBaseModel fromJson(Map<String, dynamic> json) => fromJson(json);

  @override
  String get primaryKey => 'cid';

  @override
  String get primaryValue => '$cid';
}
