import 'package:json_annotation/json_annotation.dart';

import '../base/db/db_base_model.dart';
import 'article_entity.dart';

part 'navi_entity.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 导航
@JsonSerializable(explicitToJson: true)
class NaviEntity extends DBBaseModel {
  List<ArticleEntity> articles = [];
  String? name;
  int? cid;

  NaviEntity();

  factory NaviEntity.fromJson(Map<String, dynamic> json) => _$NaviEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NaviEntityToJson(this);

  @override
  DBBaseModel fromJson(Map<String, dynamic> json) => NaviEntity.fromJson(json);

  @override
  String get primaryKey => 'cid';

  @override
  String get primaryValue => '$cid';
}
