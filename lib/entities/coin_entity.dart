import 'package:flutter_ui/base/db/db_base_model.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 用户积分表
class CoinEntity extends DBBaseModel {
  int? coinCount;
  int? level;
  String? nickname;
  String? rank;
  int? userId;
  String? username;

  CoinEntity();

  CoinEntity.fromJson(Map<String, dynamic> json) {
    coinCount = json['coinCount'];
    level = json['level'];
    nickname = json['nickname'];
    rank = json['rank'];
    userId = json['userId'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() => {
        'coinCount': coinCount,
        'level': level,
        'nickname': nickname,
        'rank': rank,
        'userId': userId,
        'username': username,
      };

  @override
  DBBaseModel fromJson(Map<String, dynamic> json) => CoinEntity.fromJson(json);

  @override
  String get primaryKey => 'userId';

  @override
  String get primaryValue => '$userId';
}
