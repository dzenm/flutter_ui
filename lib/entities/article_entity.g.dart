// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArticleEntity _$ArticleEntityFromJson(Map<String, dynamic> json) =>
    ArticleEntity()
      ..adminAdd = const BoolConvert().fromJson(json['adminAdd'])
      ..apkLink = json['apkLink'] as String?
      ..audit = json['audit'] as int?
      ..author = json['author'] as String?
      ..canEdit = const BoolConvert().fromJson(json['canEdit'])
      ..chapterId = json['chapterId'] as int?
      ..chapterName = json['chapterName'] as String?
      ..collect = const BoolConvert().fromJson(json['collect'])
      ..courseId = json['courseId'] as int?
      ..desc = json['desc'] as String?
      ..descMd = json['descMd'] as String?
      ..envelopePic = json['envelopePic'] as String?
      ..fresh = const BoolConvert().fromJson(json['fresh'])
      ..host = json['host'] as String?
      ..id = json['id'] as int?
      ..isAdminAdd = const BoolConvert().fromJson(json['isAdminAdd'])
      ..link = json['link'] as String?
      ..niceDate = json['niceDate'] as String?
      ..niceShareDate = json['niceShareDate'] as String?
      ..origin = json['origin'] as String?
      ..prefix = json['prefix'] as String?
      ..projectLink = json['projectLink'] as String?
      ..publishTime = json['publishTime'] as int?
      ..realSuperChapterId = json['realSuperChapterId'] as int?
      ..route = const BoolConvert().fromJson(json['route'])
      ..selfVisible = json['selfVisible'] as int?
      ..shareDate = json['shareDate'] as int?
      ..shareUser = json['shareUser'] as String?
      ..superChapterId = json['superChapterId'] as int?
      ..superChapterName = json['superChapterName'] as String?
      ..title = json['title'] as String?
      ..tags = const TagsConvert().fromJson(json['tags'])
      ..type = json['type'] as int?
      ..userId = json['userId'] as int?
      ..visible = json['visible'] as int?
      ..zan = json['zan'] as int?;

Map<String, dynamic> _$ArticleEntityToJson(ArticleEntity instance) =>
    <String, dynamic>{
      'adminAdd': const BoolConvert().toJson(instance.adminAdd),
      'apkLink': instance.apkLink,
      'audit': instance.audit,
      'author': instance.author,
      'canEdit': const BoolConvert().toJson(instance.canEdit),
      'chapterId': instance.chapterId,
      'chapterName': instance.chapterName,
      'collect': const BoolConvert().toJson(instance.collect),
      'courseId': instance.courseId,
      'desc': instance.desc,
      'descMd': instance.descMd,
      'envelopePic': instance.envelopePic,
      'fresh': const BoolConvert().toJson(instance.fresh),
      'host': instance.host,
      'id': instance.id,
      'isAdminAdd': const BoolConvert().toJson(instance.isAdminAdd),
      'link': instance.link,
      'niceDate': instance.niceDate,
      'niceShareDate': instance.niceShareDate,
      'origin': instance.origin,
      'prefix': instance.prefix,
      'projectLink': instance.projectLink,
      'publishTime': instance.publishTime,
      'realSuperChapterId': instance.realSuperChapterId,
      'route': const BoolConvert().toJson(instance.route),
      'selfVisible': instance.selfVisible,
      'shareDate': instance.shareDate,
      'shareUser': instance.shareUser,
      'superChapterId': instance.superChapterId,
      'superChapterName': instance.superChapterName,
      'title': instance.title,
      'tags': const TagsConvert().toJson(instance.tags),
      'type': instance.type,
      'userId': instance.userId,
      'visible': instance.visible,
      'zan': instance.zan,
    };

TagEntity _$TagEntityFromJson(Map<String, dynamic> json) => TagEntity()
  ..name = json['name'] as String?
  ..url = json['url'] as String?;

Map<String, dynamic> _$TagEntityToJson(TagEntity instance) => <String, dynamic>{
      'name': instance.name,
      'url': instance.url,
    };
