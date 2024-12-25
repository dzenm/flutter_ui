import 'package:json_annotation/json_annotation.dart';

import 'package:fbl/fbl.dart';
import 'article.dart';

part 'navi.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 导航
@JsonSerializable(explicitToJson: true)
class NaviEntity extends DBBaseEntity {
  List<ArticleEntity> articles = [];
  String? name;
  int? cid;

  NaviEntity();

  factory NaviEntity.fromJson(Map<String, dynamic> json) => _$NaviEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$NaviEntityToJson(this);
}
