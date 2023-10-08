import 'package:json_annotation/json_annotation.dart';

import '../base/base.dart';
import 'converts/bool_convert.dart';

part 'user_entity.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 用户表
@JsonSerializable(explicitToJson: true)
class UserEntity extends DBBaseEntity {
  @BoolConvert()
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

  factory UserEntity.fromJson(Map<String, dynamic> json) => _$UserEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserEntityToJson(this);

  @override
  DBBaseEntity fromJson(Map<String, dynamic> json) => _$UserEntityFromJson(json);

  @override
  String get createTableSql => '''$tableName(
    id INTEGER PRIMARY KEY NOT NULL, 
    admin BIT, 
    chapterTops TEXT, 
    coinCount INTEGER, 
    collectIds TEXT, 
    email TEXT, 
    icon TEXT, 
    nickname TEXT, 
    password TEXT, 
    publicName TEXT, 
    token TEXT, 
    type INTEGER, 
    username TEXT
  );''';

  @override
  Map<String, String> get primaryKey => {'id': '$id'};

  Future<UserEntity?> querySelf() async {
    List<UserEntity> users = await DBManager().query<UserEntity>(whereParams: {'id': SpUtil.getUserId()});
    return users.firstOrNull;
  }

  Future<void> insert(dynamic user) async {
    UserEntity? user = await querySelf();
    if (user == null) {
      await DBManager().insert<UserEntity>(user);
    } else {
      await DBManager().update<UserEntity>(user);
    }
  }

  Future<int> update(UserEntity user) async {
    return await DBManager().update<UserEntity>(user);
  }
}
