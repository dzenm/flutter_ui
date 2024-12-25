// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tree.dart';

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
  ..courseId = (json['courseId'] as num?)?.toInt()
  ..id = (json['id'] as num?)?.toInt()
  ..cover = json['cover'] as String?
  ..desc = json['desc'] as String?
  ..lisense = json['lisense'] as String?
  ..lisenseLink = json['lisenseLink'] as String?
  ..name = json['name'] as String?
  ..order = (json['order'] as num?)?.toInt()
  ..parentChapterId = (json['parentChapterId'] as num?)?.toInt()
  ..type = (json['type'] as num?)?.toInt()
  ..userControlSetTop = const BoolConvert().fromJson(json['userControlSetTop'])
  ..visible = (json['visible'] as num?)?.toInt();

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
