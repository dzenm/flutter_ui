import 'package:flutter_ui/base/db/db_base_model.dart';

///
/// Created by a0010 on 2023/2/16 16:50
/// 常用网站
class WebsiteEntity extends DBBaseModel {
  String? category;
  String? icon;
  int? id;
  String? link;
  String? name;
  int? order;
  int? visible;

  WebsiteEntity();

  WebsiteEntity.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    icon = json['icon'];
    id = json['id'];
    link = json['link'];
    name = json['name'];
    order = json['order'];
    visible = json['visible'];
  }

  @override
  DBBaseModel fromJson(Map<String, dynamic> json) => WebsiteEntity.fromJson(json);

  @override
  Map<String, dynamic> toJson() => {
        'category': category,
        'icon': icon,
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
