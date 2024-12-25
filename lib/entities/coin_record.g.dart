// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoinRecordEntity _$CoinRecordEntityFromJson(Map<String, dynamic> json) =>
    CoinRecordEntity()
      ..coinCount = (json['coinCount'] as num?)?.toInt()
      ..date = (json['date'] as num?)?.toInt()
      ..desc = json['desc'] as String?
      ..id = (json['id'] as num?)?.toInt()
      ..reason = json['reason'] as String?
      ..type = (json['type'] as num?)?.toInt()
      ..userId = (json['userId'] as num?)?.toInt()
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
