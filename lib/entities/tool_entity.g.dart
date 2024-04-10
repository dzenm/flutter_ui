// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tool_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ToolEntity _$ToolEntityFromJson(Map<String, dynamic> json) => ToolEntity()
  ..desc = json['desc'] as String?
  ..icon = json['icon'] as String?
  ..id = json['id'] as int?
  ..isNew = json['isNew'] as int?
  ..link = json['link'] as String?
  ..name = json['name'] as String?
  ..order = json['order'] as int?
  ..showInTab = json['showInTab'] as int?
  ..tabName = json['tabName'] as String?
  ..visible = json['visible'] as int?;

Map<String, dynamic> _$ToolEntityToJson(ToolEntity instance) =>
    <String, dynamic>{
      'desc': instance.desc,
      'icon': instance.icon,
      'id': instance.id,
      'isNew': instance.isNew,
      'link': instance.link,
      'name': instance.name,
      'order': instance.order,
      'showInTab': instance.showInTab,
      'tabName': instance.tabName,
      'visible': instance.visible,
    };
