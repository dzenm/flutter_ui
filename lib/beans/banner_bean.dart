import 'package:flutter_ui/db/database/base_db.dart';
import 'package:flutter_ui/db/database/db_dao.dart';

/// 轮播图
class BannerBean extends BaseDB with DBDao {
  String? desc;
  int? id;
  String? imagePath;
  int? isVisible;
  int? order;
  String? title;
  int? type;
  String? url;

  BannerBean() : super();

  BannerBean.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
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
  BannerBean fromJson(Map<String, dynamic> json) => BannerBean.fromJson(json);

  @override
  String columnString() => '''
    id INTEGER PRIMARY KEY NOT NULL, 
    "desc" TEXT,
    imagePath TEXT,
    isVisible INTEGER,
    "order" INTEGER,
    title TEXT,
    type INTEGER,
    url TEXT''';

  @override
  String getTableName() => 't_banner';
}
