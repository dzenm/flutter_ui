import 'dart:convert';

import 'package:flutter_ui/base/db/db_base_model.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 用户表
class UserEntity extends DBBaseModel {
  bool? admin;
  List<dynamic>? chapterTops;
  int? coinCount;
  List<int> collectIds = [];
  String? email;
  String? icon;
  int? id;
  String? nickname;
  String? password;
  String? publicName;
  String? token;
  int? type;
  String? username;

  UserEntity();

  UserEntity.fromJson(Map<String, dynamic> json) {
    admin = toBool(json['admin']);
    chapterTops = toList(json['chapterTops']).map((e) => e as dynamic).toList();
    coinCount = json['coinCount'];
    collectIds = toList(json['collectIds']).map((e) => e as int).toList();
    email = json['email'];
    icon = json['icon'];
    id = json['id'];
    nickname = json['nickname'];
    password = json['password'];
    publicName = json['publicName'];
    token = json['token'];
    type = json['type'];
    username = json['username'];
  }

  Map<String, dynamic> toJson() => {
        'admin': boolToInt(admin),
        'chapterTops': jsonEncode(chapterTops),
        'coinCount': coinCount,
        'collectIds': jsonEncode(collectIds),
        'email': email,
        'icon': icon,
        'id': id,
        'nickname': nickname,
        'password': password,
        'publicName': publicName,
        'token': token,
        'type': type,
        'username': username,
      };

  @override
  DBBaseModel fromJson(Map<String, dynamic> json) => UserEntity.fromJson(json);

  @override
  String get primaryKey => 'id';

  @override
  String get primaryValue => '$id';
}
