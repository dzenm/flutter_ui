// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tree_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TreeEntity _$TreeEntityFromJson(Map<String, dynamic> json) => TreeEntity()
  ..articleList = (json['articleList'] as List<dynamic>)
      .map((e) => ArticleEntity.fromJson(e as Map<String, dynamic>))
      .toList()
  ..author = json['author'] as String?
  ..children = (json['children'] as List<dynamic>)
      .map((e) => TreeEntity.fromJson(e as Map<String, dynamic>))
      .toList()
  ..courseId = json['courseId'] as int?
  ..id = json['id'] as int?
  ..cover = json['cover'] as String?
  ..desc = json['desc'] as String?
  ..lisense = json['lisense'] as String?
  ..lisenseLink = json['lisenseLink'] as String?
  ..name = json['name'] as String?
  ..order = json['order'] as int?
  ..parentChapterId = json['parentChapterId'] as int?
  ..type = json['type'] as int?
  ..userControlSetTop = const BoolConvert().fromJson(json['userControlSetTop'])
  ..visible = json['visible'] as int?;

Map<String, dynamic> _$TreeEntityToJson(TreeEntity instance) =>
    <String, dynamic>{
      'articleList': instance.articleList.map((e) => e.toJson()).toList(),
      'author': instance.author,
      'children': instance.children.map((e) => e.toJson()).toList(),
      'courseId': instance.courseId,
      'id': instance.id,
      'cover': instance.cover,
      'desc': instance.desc,
      'lisense': instance.lisense,
      'lisenseLink': instance.lisenseLink,
      'name': instance.name,
      'order': instance.order,
      'parentChapterId': instance.parentChapterId,
      'type': instance.type,
      'userControlSetTop':
          const BoolConvert().toJson(instance.userControlSetTop),
      'visible': instance.visible,
    };
