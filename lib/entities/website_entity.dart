import 'package:flutter_ui/base/db/db_base_model.dart';
import 'package:json_annotation/json_annotation.dart';
part 'website_entity.g.dart';

///
/// Created by a0010 on 2023/2/16 16:50
/// 常用网站
@JsonSerializable()
class WebsiteEntity extends DBBaseModel {
  String? category;
  String? icon;
  int? id;
  String? link;
  String? name;
  int? order;
  int? visible;

  WebsiteEntity();

  @override
  factory WebsiteEntity.fromJson(Map<String, dynamic> json) => _$WebsiteEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WebsiteEntityToJson(this);

  @override
  DBBaseModel fromJson(Map<String, dynamic> json) => fromJson(json);

  @override
  String get primaryKey => 'id';

  @override
  String get primaryValue => '$id';
}
