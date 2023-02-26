import 'package:flutter_ui/base/db/db_base_model.dart';

///
/// Created by a0010 on 2023/2/23 14:26
/// 文章
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
    adminAdd = json['adminAdd'] == 1;
    apkLink = json['apkLink'];
    audit = json['audit'];
    author = json['author'];
    canEdit = json['canEdit'] == 1;
    chapterId = json['chapterId'];
    chapterName = json['chapterName'];
    collect = json['collect'] == 1;
    courseId = json['courseId'];
    desc = json['desc'];
    descMd = json['descMd'];
    envelopePic = json['envelopePic'];
    fresh = json['fresh'] == 1;
    host = json['host'];
    id = json['id'];
    isAdminAdd = json['isAdminAdd'] == 1;
    link = json['link'];
    niceDate = json['niceDate'];
    niceShareDate = json['niceShareDate'];
    origin = json['origin'];
    prefix = json['prefix'];
    projectLink = json['projectLink'];
    publishTime = json['publishTime'];
    realSuperChapterId = json['realSuperChapterId'];
    route = json['route'] == 1;
    selfVisible = json['selfVisible'];
    shareDate = json['shareDate'];
    shareUser = json['shareUser'];
    superChapterId = json['superChapterId'];
    superChapterName = json['superChapterName'];
    title = json['title'];
    /// TODO tags未保存
    // tags = json['tags'];
    type = json['type'];
    userId = json['userId'];
    visible = json['visible'];
    zan = json['zan'];
  }

  @override
  Map<String, dynamic> toJson() => {
        'adminAdd': (adminAdd ?? false) ? 1 : 0,
        'apkLink': apkLink,
        'audit': audit,
        'author': author,
        'canEdit': (canEdit ?? false) ? 1 : 0,
        'chapterId': chapterId,
        'chapterName': chapterName,
        'collect': (collect ?? false) ? 1 : 0,
        'courseId': courseId,
        'desc': desc,
        'descMd': descMd,
        'envelopePic': envelopePic,
        'fresh': (fresh ?? false) ? 1 : 0,
        'host': host,
        'id': id,
        'isAdminAdd': (isAdminAdd ?? false) ? 1 : 0,
        'link': link,
        'niceDate': niceDate,
        'niceShareDate': niceShareDate,
        'origin': origin,
        'prefix': prefix,
        'projectLink': projectLink,
        'publishTime': publishTime,
        'realSuperChapterId': realSuperChapterId,
        'route': (route ?? false) ? 1 : 0,
        'selfVisible': selfVisible,
        'shareDate': shareDate,
        'shareUser': shareUser,
        'superChapterId': superChapterId,
        'superChapterName': superChapterName,
        'title': title,
        // 'tags': tags,
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
