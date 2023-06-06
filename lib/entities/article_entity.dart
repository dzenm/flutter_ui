import 'package:flutter_ui/base/db/db_base_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'article_entity.g.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 文章
@JsonSerializable(explicitToJson: true)
class ArticleEntity extends DBBaseModel {
  bool? adminAdd;
  String? apkLink;
  int? audit;
  String? author;
  bool? canEdit;
  int? chapterId;
  String? chapterName;
  bool? collect;
  int? courseId;
  String? desc;
  String? descMd;
  String? envelopePic;
  bool? fresh;
  String? host;
  int? id;
  bool? isAdminAdd;
  String? link;
  String? niceDate;
  String? niceShareDate;
  String? origin;
  String? prefix;
  String? projectLink;
  int? publishTime;
  int? realSuperChapterId;
  bool? route;
  int? selfVisible;
  int? shareDate;
  String? shareUser;
  int? superChapterId;
  String? superChapterName;
  String? title;
  List<TagEntity> tags = [];
  int? type;
  int? userId;
  int? visible;
  int? zan;

  ArticleEntity() : super();

  @override
  ArticleEntity.fromJson(Map<String, dynamic> json) {
    adminAdd = toBool(json['adminAdd']);
    apkLink = json['apkLink'];
    audit = json['audit'];
    author = json['author'];
    canEdit = toBool(json['canEdit']);
    chapterId = json['chapterId'];
    chapterName = json['chapterName'];
    collect = toBool(json['collect']);
    courseId = json['courseId'];
    desc = json['desc'];
    descMd = json['descMd'];
    envelopePic = json['envelopePic'];
    fresh = toBool(json['fresh']);
    host = json['host'];
    id = json['id'];
    isAdminAdd = toBool(json['isAdminAdd']);
    link = json['link'];
    niceDate = json['niceDate'];
    niceShareDate = json['niceShareDate'];
    origin = json['origin'];
    prefix = json['prefix'];
    projectLink = json['projectLink'];
    publishTime = json['publishTime'];
    realSuperChapterId = json['realSuperChapterId'];
    route = toBool(json['route']);
    selfVisible = json['selfVisible'];
    shareDate = json['shareDate'];
    shareUser = json['shareUser'];
    superChapterId = json['superChapterId'];
    superChapterName = json['superChapterName'];
    title = json['title'];
    tags = toList(json['tags']).map((e) => TagEntity.fromJson(e)).toList();
    type = json['type'];
    userId = json['userId'];
    visible = json['visible'];
    zan = json['zan'];
  }

  @override
  Map<String, dynamic> toJson() => {
        'adminAdd': boolToInt(adminAdd),
        'apkLink': apkLink,
        'audit': audit,
        'author': author,
        'canEdit': boolToInt(canEdit),
        'chapterId': chapterId,
        'chapterName': chapterName,
        'collect': boolToInt(collect),
        'courseId': courseId,
        'desc': desc,
        'descMd': descMd,
        'envelopePic': envelopePic,
        'fresh': boolToInt(fresh),
        'host': host,
        'id': id,
        'isAdminAdd': boolToInt(isAdminAdd),
        'link': link,
        'niceDate': niceDate,
        'niceShareDate': niceShareDate,
        'origin': origin,
        'prefix': prefix,
        'projectLink': projectLink,
        'publishTime': publishTime,
        'realSuperChapterId': realSuperChapterId,
        'route': boolToInt(route),
        'selfVisible': selfVisible,
        'shareDate': shareDate,
        'shareUser': shareUser,
        'superChapterId': superChapterId,
        'superChapterName': superChapterName,
        'title': title,
        'tags': toJsonString(tags),
        'type': type,
        'userId': userId,
        'visible': visible,
        'zan': zan,
      };

  @override
  ArticleEntity fromJson(Map<String, dynamic> json) => ArticleEntity.fromJson(json);

  @override
  String get primaryKey => 'id';

  @override
  String get primaryValue => '$id';
}

class TagEntity extends DBBaseModel {
  String? name;
  String? url;

  TagEntity() : super();

  @override
  TagEntity.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    url = json['url'];
  }

  @override
  Map<String, dynamic> toJson() => {
        'name': name,
        'url': url,
      };

  @override
  TagEntity fromJson(Map<String, dynamic> json) => TagEntity.fromJson(json);

  @override
  String get primaryKey => 'name';

  @override
  String get primaryValue => '$name';
}
