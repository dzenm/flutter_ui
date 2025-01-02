import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../config/build_config.dart';
import '../config/log.dart';
import '../http/http.dart';
import '../resource/resource.dart';
import 'common_dialog.dart';
import 'indicators.dart';
import 'tap.dart';

typedef InstallCallback = void Function(String filePath);

///
/// Created by a0010 on 2022/3/28 16:28
/// 更新弹窗
class UpgradeDialog extends StatelessWidget {
  final AppVersionEntity appVersion;
  final Color color;
  final InstallCallback? install;

  const UpgradeDialog({
    super.key,
    required this.appVersion,
    this.color = Colors.blue,
    this.install,
  });

  ///苹果导到应用商店，安卓内测时应用内下载apk
  static void upgrade(BuildContext context, {AppVersionEntity? appVersion}) async {
    String currentVersion = BuildConfig.packageInfo.version;
    appVersion = AppVersionEntity(
      uid: '1',
      title: '测试',
      content: '不知道更新了什么',
      url: 'https://ucdl.25pp.com/fs08/2023/08/14/6/110_612a0e357913d43e504044debbddff35.apk?cc=850312032&nrd=0&f'
          'name=%E7%99%BE%E5%BA%A6%E5%9C%B0%E5%9B%BE&productid=&packageid=601220125&pkg=com.baidu.BaiduMap&vcode=1'
          '277&yingid=pp_wap_ppcn&vh=7641e6ccaaae10b280b634ba8e225deb&sf=133168324&sh=10&appid=29805&apprd=',
      version: '1.2.0',
    );
    if (!needUpgrade(currentVersion, appVersion.version)) return;
    if (Platform.isIOS) {
      // String url = 'itms-apps://itunes.apple.com/cn/app/id414478124'; // 这是微信的地址，到时候换成自己的应用的地址
      // if (await canLaunch(url)) {
      //   await launch(url);
      // } else {
      //   throw 'Could not launch $url';
      // }
      CommonDialog.showToast('请通过应用商店进行更新');
    } else {
      Future.delayed(Duration.zero, () async {
        showDialog(
          barrierColor: Colors.black26,
          context: context,
          builder: (context) {
            return DialogWrapper(
              color: Colors.transparent,
              isTouchOutsideDismiss: false,
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

  /// 根据旧版本号和新版本号判断是否需要更新
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
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(Assets.bgUpgradeTop),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: _DownloadView(
              color: color,
              appVersion: appVersion,
              install: install,
              children: [_buildContent()],
            ),
          )
        ],
      ),
    );
  }

  /// 更新内容布局
  Widget _buildContent() {
    String desc = appVersion.content ?? '';
    return SizedBox(
      height: 100,
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
}

/// 下载布局
class _DownloadView extends StatefulWidget {
  final List<Widget> children;
  final Color color;
  final AppVersionEntity appVersion;
  final InstallCallback? install;

  const _DownloadView({
    required this.children,
    required this.color,
    required this.appVersion,
    required this.install,
  });

  @override
  State<_DownloadView> createState() => _DownloadViewState();
}

class _DownloadViewState extends State<_DownloadView> {
  double _percent = 0;
  bool _running = false;
  CancelToken? _cancel;

  void _download() async {
    if (_running) return;
    String filePath = await _defaultInstallAPKPath();
    File file = File(filePath);
    if (file.existsSync()) {
      _installAPK(filePath);
      return;
    }
    _running = false;
    _cancel = CancelToken();
    HttpsClient().download(
      widget.appVersion.url!,
      cancelToken: _cancel,
      success: (data) async {
        await file.writeAsBytes(data);
        _installAPK(filePath);
        _running = false;
        setState(() {});
      },
      progress: (percent, count, total) {
        // 减少重复刷新
        if (_percent == percent) return;
        Log.d('文件下载进度：percent=$percent');
        _running = true;
        _percent = percent;
        setState(() {});
      },
      failed: (error) async {
        Log.d('文件下载错误：error=${error.msg}');
        _running = false;
        setState(() {});
      },
    );
  }

  void _installAPK(String filePath) {
    if (widget.install != null) {
      widget.install!(filePath);
    }
  }

  /// 获取安装包的路径
  Future<String> _defaultInstallAPKPath() async {
    var external = await getExternalCacheDirectories();
    // /storage/emulated/0/Android/data/packageName/cache/
    String? cachePath = external?.firstOrNull?.path;
    String savePath = '$cachePath/app_release v${widget.appVersion.version}.apk';
    Log.d('文件路径：savePath=$savePath');
    return savePath;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...widget.children,
        ..._buildBottomButton(),
      ],
    );
  }

  /// 底部的下载和取消按钮
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
          background: widget.color,
          alignment: Alignment.center,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          onTap: () => _download(),
          child: const Text(
            '立即升级',
            style: TextStyle(color: Colors.white),
          ),
        ),
      const SizedBox(height: 8),
      TapLayout(
        height: 40,
        alignment: Alignment.center,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        onTap: () {
          _cancel?.cancel('取消下载');
          Navigator.pop(context);
        },
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
