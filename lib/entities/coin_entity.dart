import 'package:json_annotation/json_annotation.dart';

import '../base/db/db_base_model.dart';

part 'coin_entity.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 用户积分表
@JsonSerializable()
class CoinEntity extends DBBaseModel {
  int? coinCount;
  int? level;
  String? nickname;
  String? rank;
  int? userId;
  String? username;

  CoinEntity();

  factory CoinEntity.fromJson(Map<String, dynamic> json) => _$CoinEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CoinEntityToJson(this);

  @override
  DBBaseModel fromJson(Map<String, dynamic> json) => CoinEntity.fromJson(json);

  @override
  String get primaryKey => 'userId';

  @override
  String get primaryValue => '$userId';
}
