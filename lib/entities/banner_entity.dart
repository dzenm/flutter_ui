import 'package:json_annotation/json_annotation.dart';

import '../base/db/db.dart';

part 'banner_entity.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
///
/// 轮播图
@JsonSerializable()
class BannerEntity extends DBBaseEntity {
  String? desc;
  int? id;
  String? imagePath;
  int? isVisible;
  int? order;
  String? title;
  int? type;
  String? url;

  BannerEntity() : super();

  factory BannerEntity.fromJson(Map<String, dynamic> json) => _$BannerEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$BannerEntityToJson(this);

  @override
  BannerEntity fromJson(Map<String, dynamic> json) => _$BannerEntityFromJson(json);

  @override
  String get createTableSql => '''$tableName(
    id INTEGER PRIMARY KEY NOT NULL, 
    "desc" TEXT, 
    imagePath TEXT, 
    isVisible INTEGER, 
    "order" INTEGER, 
    title TEXT, 
    type INTEGER, 
    url TEXT
  );''';

  @override
  Map<String, String> get primaryKey => {'id': '$id'};

  Future<List<BannerEntity>> query() async {
    return await DBManager().query<BannerEntity>();
  }

  Future<List<int>> insert(dynamic banner) async {
    return await DBManager().insert<BannerEntity>(banner);
  }

  Future<int> update(BannerEntity banner) async {
    return await DBManager().update<BannerEntity>(banner);
  }
}
