import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/base/http/https_client.dart';
import 'package:flutter_ui/base/log/handle_error.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/res/assets.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:path_provider/path_provider.dart';

import 'common_dialog.dart';
import 'linear_percent_indicator.dart';

///
/// Created by a0010 on 2022/3/28 16:28
///
class UpgradeDialog extends StatefulWidget {
  final AppVersionEntity appVersion;
  final Color color;

  const UpgradeDialog({
    super.key,
    required this.appVersion,
    this.color = Colors.blue,
  });

  ///苹果导到应用商店，安卓内测时应用内下载apk
  static void upgrade(BuildContext context, {AppVersionEntity? appVersion}) async {
    String currentVersion = HandleError.packageInfo.version;
    appVersion = AppVersionEntity(
      uid: '1',
      title: '测试',
      content: '不知道更新了什么',
      url: 'https://dl.google.com/chrome/mac/stable/GGRO/googlechrome.dmg',
      version: '1.2.0',
    );
    if (!needUpgrade(currentVersion, appVersion.version)) return;
    if (Platform.isIOS) {
//      String url = 'itms-apps://itunes.apple.com/cn/app/id414478124?mt=8'; // 这是微信的地址，到时候换成自己的应用的地址
//      if (await canLaunch(url)){
//    await launch(url);
//    }else {
//    throw 'Could not launch $url';
//    }
    } else {
      Future.delayed(Duration.zero, () async {
        showDialog(
          barrierColor: Colors.black26,
          context: context,
          builder: (context) {
            return DialogWrapper(
              color: Colors.transparent,
              touchOutsideDismiss: false,
              backDismiss: false,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              child: UpgradeDialog(
                appVersion: appVersion!,
              ),
            );
          },
        );
      });
    }
  }

  // 根据旧版本号和新版本号判断是否需要更新
  static bool needUpgrade(String? oldVersion, String? newVersion) {
    if (oldVersion == null || newVersion == null) return false;
    List<String> newVersions = newVersion.split('.');
    List<String> oldVersions = oldVersion.split('.');
    // 获取版本号长度
    int oldLen = oldVersions.length;
    int newLen = newVersions.length;
    int len = min(oldLen, newLen);
    for (int i = 0; i < len; i++) {
      int newVersion = int.parse(newVersions[i]);
      int oldVersion = int.parse(oldVersions[i]);
      // 同位的版本号一致时跳过
      if (newVersion == oldVersion) continue;
      // 同位的版本号不一致时决定是否需要升级
      return newVersion > oldVersion;
    }
    // 如果同位的版本号完全一直，且长度相等，即为同版本，不需要升级
    if (newLen == oldLen) return false;
    // 如果新版本号比旧版本号长度长则需要升级
    return newLen > oldLen;
  }

  @override
  State<StatefulWidget> createState() => _UpgradeDialogState();
}

class _UpgradeDialogState extends State<UpgradeDialog> {
  double _percent = 0;
  bool _running = false;
  CancelToken? _cancel;

  void start() async {
    _running = false;
    _cancel = CancelToken();
    var external = await getExternalCacheDirectories();
    var cachePath = external?.first.path;
    String savePath = '$cachePath/yunyuApkUpdate.apk';
    File file = File(savePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    Log.d('下载路径：${file.path}');
    Log.d('下载路径：${widget.appVersion.url!}');
    HttpsClient.instance.download(
      widget.appVersion.url!,
      file.path,
      cancel: _cancel,
      success: (data) {
        _running = false;
        setState(() {});
      },
      progress: (percent, count, total) {
        Log.d('下载路径：$percent');
        _running = true;
        _percent = percent;
        setState(() {});
      },
      failed: (e) {
        Log.d('下载路径：${e.msg}');
        _running = false;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(Assets.image('bg_upgrade_top.png')),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContent(),
                ..._buildBottomButton(),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// 更新内容布局
  Widget _buildContent() {
    String desc = widget.appVersion.content ?? '';
    return SizedBox(
      height: 100,
      child: SingleChildScrollView(
        child: Column(children: [
          const Text('更新内容'),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  List<Widget> _buildBottomButton() {
    return [
      if (_running)
        Container(
          height: 40,
          alignment: Alignment.center,
          child: LinearPercentIndicator(
            backgroundColor: const Color(0xFFd3d6da),
            percent: _percent,
            lineHeight: 12,
            center: Text(
              '${(_percent * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontSize: 9.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 30),
            progressColor: widget.color,
          ),
        ),
      if (!_running)
        TapLayout(
          height: 40,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          background: widget.color,
          alignment: Alignment.center,
          onTap: () => start(),
          child: const Text(
            '立即升级',
            style: TextStyle(color: Colors.white),
          ),
        ),
      const SizedBox(height: 8),
      TapLayout(
        onTap: () {
          _cancel?.cancel();
          Navigator.pop(context);
        },
        height: 32,
        alignment: Alignment.center,
        child: const Text('稍后升级'),
      ),
    ];
  }
}

/// 版本更新的数据对应的实体类
class AppVersionEntity {
  String? uid;
  String? title;
  String? content;
  String? url;
  String? version;

  AppVersionEntity({this.uid, this.title, this.content, this.url, this.version});

  AppVersionEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    title = json['title'];
    content = json['content'];
    url = json['url'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'title': title,
        'content': content,
        'url': url,
        'version': version,
      };

  @override
  String toString() {
    StringBuffer sb = StringBuffer('{');
    sb.write("\"uid\":\"$uid\"");
    sb.write("\"title\":\"$title\"");
    sb.write(",\"content\":\"$content\"");
    sb.write(",\"url\":\"$url\"");
    sb.write(",\"version\":\"$version\"");
    sb.write('}');
    return sb.toString();
  }
}
