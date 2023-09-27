import 'package:json_annotation/json_annotation.dart';

import '../base/db/db.dart';
import 'converts/bool_convert.dart';

part 'user_entity.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 用户表
@JsonSerializable(explicitToJson: true)
class UserEntity extends DBBaseModel {
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
  DBBaseModel fromJson(Map<String, dynamic> json) => _$UserEntityFromJson(json);

  @override
  String get primaryKey => 'id';

  @override
  String get primaryValue => '$id';
}
