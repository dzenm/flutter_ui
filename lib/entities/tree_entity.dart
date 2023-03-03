import 'package:flutter_ui/base/db/db_base_model.dart';

import 'article_entity.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 体系
class TreeEntity extends DBBaseModel {
  List<ArticleEntity> articleList = [];
  String? author;
  List<TreeEntity> children = [];
  int? courseId;
  int? id;
  String? cover;
  String? desc;
  String? lisense;
  String? lisenseLink;
  String? name;
  int? order;
  int? parentChapterId;
  int? type;
  bool? userControlSetTop;
  int? visible;

  TreeEntity();

  TreeEntity.fromJson(Map<String, dynamic> json) {
    articleList = toList(json['articleList']).map((e) => ArticleEntity.fromJson(e)).toList();
    author = json['author'];
    children = toList(json['children']).map((e) => TreeEntity.fromJson(e)).toList();
    courseId = json['courseId'];
    id = json['id'];
    cover = json['cover'];
    desc = json['desc'];
    lisense = json['lisense'];
    lisenseLink = json['lisenseLink'];
    name = json['name'];
    order = json['order'];
    parentChapterId = json['parentChapterId'];
    type = json['type'];
    userControlSetTop = toBool(json['userControlSetTop']);
    visible = json['visible'];
  }

  @override
  DBBaseModel fromJson(Map<String, dynamic> json) => TreeEntity.fromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        'articleList': toJsonString(articleList),
        'author': author,
        'children': toJsonString(children),
        'courseId': courseId,
        'id': id,
        'cover': cover,
        'desc': desc,
        'lisense': lisense,
        'lisenseLink': lisenseLink,
        'name': name,
        'order': order,
        'parentChapterId': parentChapterId,
        'type': type,
        'userControlSetTop': boolToInt(userControlSetTop),
        'visible': visible,
      };

  @override
  String get primaryKey => 'id';

  @override
  String get primaryValue => '$id';
}
