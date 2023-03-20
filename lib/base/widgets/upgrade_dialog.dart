import 'package:flutter/material.dart';

import 'tap_layout.dart';

///
/// Created by a0010 on 2022/3/28 16:28
///
class UpgradeDialog extends StatelessWidget {
  final String version; // 展示的新版本号
  final List<String> desc; // 展示新版本更新的描述信息
  final GestureTapCallback? onTap;

  const UpgradeDialog({
    super.key,
    required this.version,
    required this.desc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        // 版本号
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Flexible(
            child: RichText(
              text: TextSpan(
                text: '新版本',
                style: const TextStyle(color: Colors.red, fontSize: 18),
                children: [TextSpan(text: version)],
              ),
            ),
          )
        ]),
        const SizedBox(height: 16),

        // 更新的具体内容
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: desc.map((value) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(value, style: const TextStyle(color: Colors.red, height: 2)),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // 分割线
        Container(
          height: 0.5,
        ),

        // 取消和升级按钮
        Row(children: [
          Expanded(
            flex: 1,
            child: TapLayout(
              height: 48,
              child: const Text('关闭'),
              onTap: () => Navigator.pop(context),
            ),
          ),
          Expanded(
            flex: 1,
            child: TapLayout(
              height: 48,
              background: Colors.red,
              onTap: onTap,
              child: const Text('立即升级', style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ]),
    );
  }
}

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
    StringBuffer sb = StringBuffer('{');
    sb.write("\"title\":\"$title\"");
    sb.write(",\"content\":\"$content\"");
    sb.write(",\"url\":\"$url\"");
    sb.write(",\"version\":\"$version\"");
    sb.write('}');
    return sb.toString();
  }
}
