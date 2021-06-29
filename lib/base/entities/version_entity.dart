/// 版本更新的数据对应的实体类
class VersionEntity {
  String? title;
  String? content;
  String? url;
  String? version;

  VersionEntity({this.title, this.content, this.url, this.version});

  VersionEntity.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    content = json['content'];
    url = json['url'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'url': url,
        'version': version,
      };

  @override
  String toString() {
    StringBuffer sb = new StringBuffer('{');
    sb.write("\"title\":\"$title\"");
    sb.write(",\"content\":\"$content\"");
    sb.write(",\"url\":\"$url\"");
    sb.write(",\"version\":\"$version\"");
    sb.write('}');
    return sb.toString();
  }
}
