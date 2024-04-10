// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_record_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinRecordEntity _$CoinRecordEntityFromJson(Map<String, dynamic> json) =>
    CoinRecordEntity()
      ..coinCount = json['coinCount'] as int?
      ..date = json['date'] as int?
      ..desc = json['desc'] as String?
      ..id = json['id'] as int?
      ..reason = json['reason'] as String?
      ..type = json['type'] as int?
      ..userId = json['userId'] as int?
      ..username = json['username'] as String?;

Map<String, dynamic> _$CoinRecordEntityToJson(CoinRecordEntity instance) =>
    <String, dynamic>{
      'coinCount': instance.coinCount,
      'date': instance.date,
      'desc': instance.desc,
      'id': instance.id,
      'reason': instance.reason,
      'type': instance.type,
      'userId': instance.userId,
      'username': instance.username,
    };
