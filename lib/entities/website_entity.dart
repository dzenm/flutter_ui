import 'package:json_annotation/json_annotation.dart';

import '../base/db/db.dart';

part 'website_entity.g.dart';

///
/// Created by a0010 on 2023/2/16 16:50
/// 常用网站
@JsonSerializable()
class WebsiteEntity extends DBBaseEntity {
  int? id;
  String? category;
  String? icon;
  String? link;
  String? name;
  int? order;
  int? visible;

  WebsiteEntity();

  factory WebsiteEntity.fromJson(Map<String, dynamic> json) => _$WebsiteEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$WebsiteEntityToJson(this);

  @override
  DBBaseEntity fromJson(Map<String, dynamic> json) => _$WebsiteEntityFromJson(json);

  @override
  String get createTableSql => '''$tableName(
    id INTEGER PRIMARY KEY NOT NULL, 
    category TEXT, 
    icon TEXT, 
    link TEXT, 
    name TEXT, 
    "order" INTEGER, 
    visible INTEGER
  );''';

  @override
  Map<String, String> get primaryKey => {'id': '$id'};

  Future<List<WebsiteEntity>> query() async {
    return await DBManager().query<WebsiteEntity>();
  }

  Future<List<int>> insert(dynamic website) async {
    return await DBManager().insert<WebsiteEntity>(website);
  }

  Future<int> update(WebsiteEntity website) async {
    return await DBManager().update<WebsiteEntity>(website);
  }
}
