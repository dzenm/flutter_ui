import 'package:flutter_ui/base/db/db_base_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_entity.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 用户表
@JsonSerializable()
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

  @override
  factory UserEntity.fromJson(Map<String, dynamic> json) => _$UserEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserEntityToJson(this);

  @override
  String get primaryKey => 'id';

  @override
  String get primaryValue => '$id';

  @override
  DBBaseModel fromJson(Map<String, dynamic> json) => fromJson(json);
}
