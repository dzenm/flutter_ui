// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'website.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebsiteEntity _$WebsiteEntityFromJson(Map<String, dynamic> json) =>
    WebsiteEntity()
      ..id = (json['id'] as num?)?.toInt()
      ..category = json['category'] as String?
      ..icon = json['icon'] as String?
      ..link = json['link'] as String?
      ..name = json['name'] as String?
      ..order = (json['order'] as num?)?.toInt()
      ..visible = (json['visible'] as num?)?.toInt();

Map<String, dynamic> _$WebsiteEntityToJson(WebsiteEntity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'icon': instance.icon,
      'link': instance.link,
      'name': instance.name,
      'order': instance.order,
      'visible': instance.visible,
    };
