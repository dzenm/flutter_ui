import 'package:flutter_ui/base/db/db_base_model.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 热词
class HotkeyEntity extends DBBaseModel {
  int? id;
  String? link;
  String? name;
  int? order;
  int? visible;

  HotkeyEntity();

  HotkeyEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    link = json['link'];
    name = json['name'];
    order = json['order'];
    visible = json['visible'];
  }

  @override
  DBBaseModel fromJson(Map<String, dynamic> json) => HotkeyEntity.fromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'link': link,
        'name': name,
        'order': order,
        'visible': visible,
      };

  @override
  String get primaryKey => 'id';

  @override
  String get primaryValue => '$id';
}
