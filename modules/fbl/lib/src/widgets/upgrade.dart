import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

typedef InstallCallback = void Function(String filePath);

typedef PrepareCallback = Future<bool> Function();

///
/// Created by a0010 on 2022/3/28 16:28
/// 更新弹窗
class UpgradeView extends StatelessWidget {
  final AppVersionEntity version;
  final Widget child;

  const UpgradeView({
    super.key,
    required this.version,
    required this.child,
  });

  ///苹果导到应用商店，安卓内测时应用内下载apk
  static Future<bool?> show(
    BuildContext context, {
    required AppVersionEntity version,
    InstallCallback? onInstall,
    PrepareCallback? onPrepare,
  }) async {
    String currentVersion = BuildConfig.packageInfo.version;
    if (!needUpgrade(currentVersion, version.version)) return null;
    var result = await showDialog<bool>(
      barrierColor: Colors.black26,
      context: context,
      builder: (context) {
        Widget child = UpgradeView(
          version: version,
          child: _DownloadView(
            version: version,
            color: Colors.blue,
            // savePath: savePath,
            onInstall: onInstall,
            onPrepare: onPrepare,
          ),
        );
        return DialogWrapper(
          color: Colors.transparent,
          isTouchOutsideDismiss: false,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          child: child,
        );
      },
    );
    return result;
  }

  /// 根据旧版本号和新版本号判断是否需要更新
  static bool needUpgrade(String? oldVersion, String? newVersion) {
    if (oldVersion == null || newVersion == null) return false;
    List<String> newVs = newVersion.split('.');
    List<String> oldVs = oldVersion.split('.');
    // 获取版本号长度
    int oldLen = oldVs.length;
    int newLen = newVs.length;
    int len = min(oldLen, newLen);
    for (int i = 0; i < len; i++) {
      int newV = int.parse(newVs[i]);
      int oldV = int.parse(oldVs[i]);
      // 同位的版本号一致时跳过
      if (newV == oldV) continue;
      // 同位的版本号不一致时决定是否需要升级
      return newV > oldV;
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
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(Assets.upgradeTopBg),
            _buildUpgradeView(),
          ],
        ),
      ),
    );
  }

  Widget _buildUpgradeView() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Align(
          alignment: Alignment.centerLeft,
          child: _buildContent(),
        ),
        child,
      ]),
    );
  }

  /// 更新内容布局
  Widget _buildContent() {
    String desc = version.content ?? '';
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
  final AppVersionEntity version;
  final Color? color;
  final String? savePath;
  final InstallCallback? onInstall;
  final PrepareCallback? onPrepare;

  const _DownloadView({
    required this.version,
    this.color,
    this.savePath,
    this.onInstall,
    this.onPrepare,
  });

  @override
  State<_DownloadView> createState() => _DownloadViewState();
}

class _DownloadViewState extends State<_DownloadView> {
  double _percent = 0;
  bool _isRunning = false;
  CancelToken? _cancel;

  void _download() async {
    if (_isRunning) return;
    _isRunning = true;
    if (widget.onPrepare != null) {
      if (await widget.onPrepare!()) {
        return;
      }
    }
    String filePath = widget.savePath ?? await _defaultInstallAPKPath();
    File file = File(filePath);
    if (file.existsSync()) {
      _installAPK(filePath);
      return;
    }
    _cancel = CancelToken();
    await HttpsClient().download(
      widget.version.url!,
      cancelToken: _cancel,
      success: (data) async {
        await file.writeAsBytes(data);
        _installAPK(filePath);
        setState(() {});
      },
      progress: (percent, count, total) {
        // 减少重复刷新
        if (_percent == percent) return;
        Log.d('文件下载进度：percent=$percent');
        _percent = percent;
        setState(() {});
      },
      failed: (error) async {
        Log.d('文件下载错误：error=${error.msg}');
        _isRunning = false;
        setState(() {});
      },
    );
  }

  void _installAPK(String filePath) {
    Navigator.pop(context, true);
    _isRunning = false;
    if (widget.onInstall != null) {
      widget.onInstall!(filePath);
    }
  }

  /// 获取安装包的路径
  Future<String> _defaultInstallAPKPath() async {
    var external = await getExternalCacheDirectories();
    // /storage/emulated/0/Android/data/packageName/cache/
    String? cachePath = external?.firstOrNull?.path;
    String savePath = '$cachePath/app_release v${widget.version.version}.apk';
    Log.d('文件路径：savePath=$savePath');
    return savePath;
  }

  @override
  void dispose() {
    super.dispose();
    _cancel?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      _buildPercentView(),
      _buildUpgradeView(),
      const SizedBox(height: 8),
      _buildCancelView(),
    ]);
  }

  Widget _buildPercentView() {
    if (!_isRunning) {
      return const SizedBox.shrink();
    }
    return Container(
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
    );
  }

  Widget _buildUpgradeView() {
    if (_isRunning) {
      return const SizedBox.shrink();
    }
    return TapLayout(
      height: 40,
      background: widget.color,
      alignment: Alignment.center,
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      onTap: () => _download(),
      child: const Text(
        '立即升级',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildCancelView() {
    return TapLayout(
      height: 40,
      alignment: Alignment.center,
      borderRadius: const BorderRadius.all(Radius.circular(4)),
      onTap: () {
        _cancel?.cancel('取消下载');
        Navigator.pop(context, false);
      },
      child: const Text('稍后升级'),
    );
  }
}

/// 版本更新的数据对应的实体类
class AppVersionEntity {
  String? uid;
  String? title;
  String? content;
  String? url;
  int? status; // 0为未发布，1为已发布
  String? version;

  AppVersionEntity({this.uid, this.title, this.content, this.url, this.status = 0, this.version});

  AppVersionEntity.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    title = json['title'];
    content = json['content'];
    url = json['url'];
    status = json['status'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'title': title,
        'content': content,
        'url': url,
        'status': status,
        'version': version,
      };

  @override
  String toString() {
    StringBuffer sb = StringBuffer('{');
    sb.write("\"uid\":\"$uid\"");
    sb.write("\"title\":\"$title\"");
    sb.write(",\"content\":\"$content\"");
    sb.write(",\"url\":\"$url\"");
    sb.write(",\"status\":\"$status\"");
    sb.write(",\"version\":\"$version\"");
    sb.write('}');
    return sb.toString();
  }
}
