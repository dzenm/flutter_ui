import 'package:flutter_ui/base/db/db_base_model.dart';
import 'package:flutter_ui/entities/article_entity.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 导航
class NaviEntity extends DBBaseModel {
  List<ArticleEntity> articles = [];
  String? name;
  int? cid;

  NaviEntity();

  NaviEntity.fromJson(Map<String, dynamic> json) {
    if (json['articles'] != null) {
      articles = (json['articles'] as List<dynamic>).map((e) => ArticleEntity.fromJson(e)).toList();
    }
    name = json['name'];
    cid = json['cid'];
  }

  @override
  DBBaseModel fromJson(Map<String, dynamic> json) => NaviEntity.fromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        'articles': articles.map((e) => e.toJson()).toList(),
        'name': name,
        'cid': cid,
      };

  @override
  String get primaryKey => 'cid';

  @override
  String get primaryValue => '$cid';
}
