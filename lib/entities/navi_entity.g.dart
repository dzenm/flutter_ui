// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navi_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NaviEntity _$NaviEntityFromJson(Map<String, dynamic> json) => NaviEntity()
  ..articles = (json['articles'] as List<dynamic>)
      .map((e) => ArticleEntity.fromJson(e as Map<String, dynamic>))
      .toList()
  ..name = json['name'] as String?
  ..cid = json['cid'] as int?;

Map<String, dynamic> _$NaviEntityToJson(NaviEntity instance) =>
    <String, dynamic>{
      'articles': instance.articles.map((e) => e.toJson()).toList(),
      'name': instance.name,
      'cid': instance.cid,
    };
