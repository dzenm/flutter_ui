import 'package:json_annotation/json_annotation.dart';

import '../base/db/db.dart';

part 'medicine_entity.g.dart';

///
/// Created by a0010 on 2023/2/16 16:50
///
@JsonSerializable()
class MedicineEntity extends DBBaseEntity {
  String? title;
  String? content;

  MedicineEntity();

  factory MedicineEntity.fromJson(Map<String, dynamic> json) => _$MedicineEntityFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$MedicineEntityToJson(this);

  @override
  MedicineEntity fromJson(Map<String, dynamic> json) => _$MedicineEntityFromJson(json);

  @override
  String get primaryKey => '$title';
}
