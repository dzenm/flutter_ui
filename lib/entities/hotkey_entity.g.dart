// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hotkey_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HotkeyEntity _$HotkeyEntityFromJson(Map<String, dynamic> json) => HotkeyEntity()
  ..id = json['id'] as int?
  ..link = json['link'] as String?
  ..name = json['name'] as String?
  ..order = json['order'] as int?
  ..visible = json['visible'] as int?;

Map<String, dynamic> _$HotkeyEntityToJson(HotkeyEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'link': instance.link,
      'name': instance.name,
      'order': instance.order,
      'visible': instance.visible,
    };
