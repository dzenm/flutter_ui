import 'package:flutter_ui/base/db/db_base_model.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 收藏
class CollectEntity extends DBBaseModel {
  String? author;
  int? chapterId;
  String? chapterName;
  int? courseId;
  String? desc;
  String? envelopePic;
  int? id;
  String? link;
  String? niceDate;
  String? origin;
  int? originId;
  int? publishTime;
  String? title;
  int? userId;
  int? visible;
  int? zan;

  CollectEntity();

  CollectEntity.fromJson(Map<String, dynamic> json) {
    author = json['author'];
    chapterId = json['chapterId'];
    chapterName = json['chapterName'];
    courseId = json['courseId'];
    desc = json['desc'];
    envelopePic = json['envelopePic'];
    id = json['id'];
    link = json['link'];
    niceDate = json['niceDate'];
    origin = json['origin'];
    originId = json['originId'];
    publishTime = json['publishTime'];
    title = json['title'];
    userId = json['userId'];
    visible = json['visible'];
    zan = json['zan'];
  }

  Map<String, dynamic> toJson() => {
        'author': author,
        'chapterId': chapterId,
        'chapterName': chapterName,
        'courseId': courseId,
        'desc': desc,
        'envelopePic': envelopePic,
        'id': id,
        'link': link,
        'niceDate': niceDate,
        'origin': origin,
        'originId': originId,
        'publishTime': publishTime,
        'title': title,
        'userId': userId,
        'visible': visible,
        'zan': zan,
      };

  @override
  CollectEntity fromJson(Map<String, dynamic> json) => CollectEntity.fromJson(json);

  @override
  String get primaryKey => 'id';

  @override
  String get primaryValue => '$id';
}
