// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingEntity _$SettingEntityFromJson(Map<String, dynamic> json) =>
    SettingEntity()
      ..id = json['id'] as String?
      ..theme = json['theme'] as String?
      ..locale = json['locale'] as String?;

Map<String, dynamic> _$SettingEntityToJson(SettingEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'theme': instance.theme,
      'locale': instance.locale,
    };
