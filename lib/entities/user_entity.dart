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
    admin = json['admin'] == 1;
    chapterTops = json['chapterTops'];
    coinCount = json['coinCount'];
    dynamic value = json['collectIds'];
    List<dynamic> list = value is List ? value : jsonDecode(value) as List<dynamic>;
    collectIds = list.map((e) => e as int).toList();
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
        'admin': (admin ?? false) ? 1 : 0,
        'chapterTops': chapterTops,
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
