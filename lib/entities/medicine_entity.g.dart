// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicineEntity _$MedicineEntityFromJson(Map<String, dynamic> json) =>
    MedicineEntity()
      ..title = json['title'] as String?
      ..content = json['content'] as String?;

Map<String, dynamic> _$MedicineEntityToJson(MedicineEntity instance) =>
    <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
    };
