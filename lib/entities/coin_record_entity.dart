import 'package:json_annotation/json_annotation.dart';

import 'package:fbl/fbl.dart';

part 'coin_record_entity.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 用户积分记录表
@JsonSerializable()
class CoinRecordEntity extends DBBaseEntity {
  int? coinCount;
  int? date;
  String? desc;
  int? id;
  String? reason;
  int? type;
  int? userId;
  String? username;

  CoinRecordEntity();

  factory CoinRecordEntity.fromJson(Map<String, dynamic> json) => _$CoinRecordEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CoinRecordEntityToJson(this);
}
