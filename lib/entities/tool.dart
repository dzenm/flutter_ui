import 'package:json_annotation/json_annotation.dart';

import 'package:fbl/fbl.dart';

part 'tool.g.dart';

///
/// Created by a0010 on 2023/8/9 16:27
/// 工具实体类
@JsonSerializable()
class ToolEntity extends DBBaseEntity {
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
}
