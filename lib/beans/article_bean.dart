class ArticleBean {
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
  String? link;
  String? niceDate;
  String? niceShareDate;
  String? origin;
  String? prefix;
  String? projectLink;
  int? publishTime;
  int? realSuperChapterId;
  int? selfVisible;
  int? shareDate;
  String? shareUser;
  int? superChapterId;
  String? superChapterName;
  List<dynamic>? tags;
  String? title;
  int? type;
  int? userId;
  int? visible;
  int? zan;

  ArticleBean.fromJson(Map<String, dynamic> json) {
    apkLink = json['apkLink'];
    audit = json['audit'];
    canEdit = json['canEdit'];
    chapterId = json['chapterId'];
    chapterName = json['chapterName'];
    collect = json['collect'];
    courseId = json['courseId'];
    desc = json['desc'];
    descMd = json['descMd'];
    envelopePic = json['envelopePic'];
    fresh = json['fresh'];
    host = json['host'];
    id = json['id'];
    link = json['link'];
    niceDate = json['niceDate'];
    niceShareDate = json['niceShareDate'];
    origin = json['origin'];
    prefix = json['prefix'];
    projectLink = json['projectLink'];
    publishTime = json['publishTime'];
    realSuperChapterId = json['realSuperChapterId'];
    selfVisible = json['selfVisible'];
    shareDate = json['shareDate'];
    shareUser = json['shareUser'];
    superChapterId = json['superChapterId'];
    superChapterName = json['superChapterName'];
    tags = json['tags'];
    title = json['title'];
    type = json['type'];
    userId = json['userId'];
    visible = json['visible'];
    zan = json['zan'];
  }

  Map<String, dynamic> toJson() => {
        'apkLink': apkLink,
        'audit': audit,
        'canEdit': canEdit,
        'chapterId': chapterId,
        'chapterName': chapterName,
        'collect': collect,
        'courseId': courseId,
        'desc': desc,
        'descMd': descMd,
        'envelopePic': envelopePic,
        'fresh': fresh,
        'host': host,
        'id': id,
        'link': link,
        'niceDate': niceDate,
        'niceShareDate': niceShareDate,
        'origin': origin,
        'prefix': prefix,
        'projectLink': projectLink,
        'publishTime': publishTime,
        'realSuperChapterId': realSuperChapterId,
        'selfVisible': selfVisible,
        'shareDate': shareDate,
        'shareUser': shareUser,
        'superChapterId': superChapterId,
        'superChapterName': superChapterName,
        'tags': tags,
        'title': title,
        'type': type,
        'userId': userId,
        'visible': visible,
        'zan': zan,
      };
}
