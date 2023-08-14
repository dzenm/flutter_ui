import 'package:json_annotation/json_annotation.dart';

import '../base/db/db_base_model.dart';

part 'setting_entity.g.dart';

///
/// Created by a0010 on 2023/8/14 09:58
/// 设置的实体类
@JsonSerializable(explicitToJson: true)
class SettingEntity extends DBBaseModel {
  String? id;
  String? theme; // 主题设置
  String? locale; // 语言设置

  SettingEntity();

  factory SettingEntity.fromJson(Map<String, dynamic> json) => _$SettingEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SettingEntityToJson(this);

  @override
  DBBaseModel fromJson(Map<String, dynamic> json) => SettingEntity.fromJson(json);

  @override
  String get primaryKey => 'id';

  @override
  String get primaryValue => '$id';
}