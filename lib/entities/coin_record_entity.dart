import 'package:flutter_ui/base/db/db_base_model.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 用户积分记录表
class CoinRecordEntity extends DBBaseModel {
  int? coinCount;
  int? date;
  String? desc;
  int? id;
  String? reason;
  int? type;
  int? userId;
  String? username;

  CoinRecordEntity();

  CoinRecordEntity.fromJson(Map<String, dynamic> json) {
    coinCount = json['coinCount'];
    date = json['date'];
    desc = json['desc'];
    id = json['id'];
    reason = json['reason'];
    type = json['type'];
    userId = json['userId'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() => {
        'coinCount': coinCount,
        'date': date,
        'desc': desc,
        'id': id,
        'reason': reason,
        'type': type,
        'userId': userId,
        'username': username,
      };

  @override
  DBBaseModel fromJson(Map<String, dynamic> json) => CoinRecordEntity.fromJson(json);

  @override
  String get primaryKey => 'id';

  @override
  String get primaryValue => '$id';
}
