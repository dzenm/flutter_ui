import 'package:flutter_ui/base/db/db_base_model.dart';

/// 轮播图
class BannerEntity extends DBBaseModel {
  String? desc;
  int? id;
  String? imagePath;
  int? isVisible;
  int? order;
  String? title;
  int? type;
  String? url;

  BannerEntity() : super();

  BannerEntity.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    desc = json['desc'];
    id = json['id'];
    imagePath = json['imagePath'];
    isVisible = json['isVisible'];
    order = json['order'];
    title = json['title'];
    type = json['type'];
    url = json['url'];
  }

  @override
  Map<String, dynamic> toJson() => {
        "desc": desc,
        "id": id,
        "imagePath": imagePath,
        "isVisible": isVisible,
        "order": order,
        "title": title,
        "type": type,
        "url": url,
      };

  @override
  BannerEntity fromJson(Map<String, dynamic> json) => BannerEntity.fromJson(json);
}
