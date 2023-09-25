import 'package:json_annotation/json_annotation.dart';

import '../base/db/db.dart';

part 'tool_entity.g.dart';

///
/// Created by a0010 on 2023/8/9 16:27
/// 工具实体类
@JsonSerializable()
class ToolEntity extends DBBaseModel {
  String? desc;
  String? icon;
  int? id;
  int? isNew;
  String? link;
  String? name;
  int? order;
  int? showInTab;
  String? tabName;
  int? visible;

  ToolEntity() : super();

  factory ToolEntity.fromJson(Map<String, dynamic> json) => _$ToolEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ToolEntityToJson(this);

  @override
  ToolEntity fromJson(Map<String, dynamic> json) => ToolEntity.fromJson(json);

  @override
  String get primaryKey => 'id';

  @override
  String get primaryValue => '$id';
}
