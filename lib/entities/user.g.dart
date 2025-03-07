// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserEntity _$UserEntityFromJson(Map<String, dynamic> json) => UserEntity()
  ..admin = const BoolConvert().fromJson(json['admin'])
  ..chapterTops = json['chapterTops'] as List<dynamic>?
  ..coinCount = (json['coinCount'] as num?)?.toInt()
  ..collectIds = (json['collectIds'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList()
  ..email = json['email'] as String?
  ..icon = json['icon'] as String?
  ..id = (json['id'] as num?)?.toInt()
  ..nickname = json['nickname'] as String?
  ..password = json['password'] as String?
  ..publicName = json['publicName'] as String?
  ..token = json['token'] as String?
  ..type = (json['type'] as num?)?.toInt()
  ..username = json['username'] as String?;

Map<String, dynamic> _$UserEntityToJson(UserEntity instance) =>
    <String, dynamic>{
      'admin': const BoolConvert().toJson(instance.admin),
      'chapterTops': instance.chapterTops,
      'coinCount': instance.coinCount,
      'collectIds': instance.collectIds,
      'email': instance.email,
      'icon': instance.icon,
      'id': instance.id,
      'nickname': instance.nickname,
      'password': instance.password,
      'publicName': instance.publicName,
      'token': instance.token,
      'type': instance.type,
      'username': instance.username,
    };
