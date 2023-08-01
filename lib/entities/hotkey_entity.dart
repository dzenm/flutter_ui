import 'package:json_annotation/json_annotation.dart';

import '../base/db/db_base_model.dart';

part 'hotkey_entity.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 热词
@JsonSerializable()
class HotkeyEntity extends DBBaseModel {
  int? id;
  String? link;
  String? name;
  int? order;
  int? visible;

  HotkeyEntity();

  factory HotkeyEntity.fromJson(Map<String, dynamic> json) => _$HotkeyEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HotkeyEntityToJson(this);

  @override
  DBBaseModel fromJson(Map<String, dynamic> json) => HotkeyEntity.fromJson(json);

  @override
  String get primaryKey => 'id';

  @override
  String get primaryValue => '$id';
}
