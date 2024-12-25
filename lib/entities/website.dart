import 'package:json_annotation/json_annotation.dart';

import 'package:fbl/fbl.dart';

part 'website.g.dart';

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
  String get createTableSql => '''$tableName(
    id INTEGER PRIMARY KEY NOT NULL,  
    category TEXT, 
    icon TEXT, 
    link TEXT, 
    name TEXT, 
    "order" INTEGER, 
    visible INTEGER
  );''';

  Future<List<WebsiteEntity>> query() async {
    List<dynamic> list = await DBManager().query(tableName);
    return list.map((e) => WebsiteEntity.fromJson(e)).toList();
  }

  Future<int> insert(WebsiteEntity website) async {
    return await DBManager().insert(tableName, website.toJson());
  }

  Future<int> update(WebsiteEntity website) async {
    return await DBManager().update(tableName, website.toJson(), where: 'id = ?', whereArgs: [website.id]);
  }
}
