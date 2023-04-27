import 'package:flutter_ui/base/db/db_base_model.dart';

///
/// Created by a0010 on 2023/2/16 16:50
///
class MedicineEntity extends DBBaseModel {
  String? title;
  String? content;

  MedicineEntity();

  MedicineEntity.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
      };

  @override
  MedicineEntity fromJson(Map<String, dynamic> json) => MedicineEntity.fromJson(json);

  @override
  String get primaryKey => '$title';
}
