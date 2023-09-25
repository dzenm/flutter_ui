import 'package:json_annotation/json_annotation.dart';

import '../base/db/db.dart';

part 'banner_entity.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
///
/// 轮播图
@JsonSerializable()
class BannerEntity extends DBBaseModel {
  String? desc;
  int? id;
  String? imagePath;
  int? isVisible;
  int? order;
  String? title;
  int? type;
  String? url;

  BannerEntity() : super();

  factory BannerEntity.fromJson(Map<String, dynamic> json) => _$BannerEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BannerEntityToJson(this);

  @override
  BannerEntity fromJson(Map<String, dynamic> json) => BannerEntity.fromJson(json);

  @override
  String get primaryKey => 'id';

  @override
  String get primaryValue => '$id';
}
