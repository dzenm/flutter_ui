import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/notification_util.dart';
import '../widgets/floating_button.dart';
import 'http_entity.dart';
import 'naught_page.dart';

/// 悬浮窗
class Naughty {
  Naughty._internal();

  static final Naughty _instance = Naughty._internal();

  static Naughty get instance => _instance;

  factory Naughty() => _instance;

  Widget? _child;
  BuildContext? _context;

  BuildContext get context => _context!;

  OverlayEntry? _overlayEntry;

  List<HTTPEntity> httpRequests = [];

  bool _showing = false;

  /// 初始化, 设置子widget
  void init(BuildContext context, {Widget? child}) {
    if (_context != null && child == null) return;
    _context = context;
    _child = child;
  }

  Future<void> _createOverlay() async {
    if (kIsWeb) return;
    _overlayEntry ??= OverlayEntry(builder: (BuildContext context) {
      return _child ??
          FloatingButton(
            onTap: () => push(context, const NaughtPage()),
            imageProvider: AssetImage('assets/images/ic_vnote.png'),
          );
    });
    if (_context != null) {
      Overlay.of(_context!)?.insert(_overlayEntry!);
    }
  }

  /// 显示悬浮窗
  void show() {
    if (kIsWeb) return;
    if (_showing) return;
    _showing = true;
    Future.delayed(Duration.zero, _createOverlay);
  }

  /// 隐藏悬浮窗
  void dismiss() {
    if (kIsWeb) return;
    if (!_showing) return;
    _showing = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// 展示通知
  void showNotification({String? title, String? body}) {
    if (kIsWeb) return;
    NotificationUtil().showNotification(
      title: title,
      body: body,
      onTap: (payload) async => push(context, const NaughtPage()),
    );
  }

  /// 打开一个新的页面
  void push(BuildContext context, Widget page) {
    Route route = MaterialPageRoute(
      builder: (BuildContext context) => page,
      settings: RouteSettings(name: page.toStringShort()),
    );
    Navigator.push(context, route);
  }

  /// 获取数据库文件夹所有数据库文件
  Future<List<String>> getDBFiles() async {
    if (kIsWeb) return [];
    String parent = await getDatabasesPath();
    List<String> files = [];
    Directory(parent).listSync().forEach((element) {
      if (element.path.endsWith('.db')) {
        files.add(element.path);
      }
    });
    return files;
  }

  /// 获取文件名通过路径或者文件，例：
  /// path   = /data/user/0/com.dzenm.flutter_ui/databases/db_4824.db
  /// result = db_4824.db
  String getFileName(dynamic file) {
    String path = '';
    if (file is File) {
      path = file.path;
    } else {
      path = file.toString();
    }
    return path.split('/').last;
  }

  /// 格式化文件大小，例：
  /// len  = 13353
  /// size = 133.53 B
  String formatSize(int? len) {
    if (len == null) return '0 B';

    List<String> suffix = [" B", " KB", " MB", " GB", " TB", "PB"];

    int index = 0;
    // 因为要保存小数点，所以需大于102400以便用于后面进行小数分解的运算，index是判断以哪一个单位结尾
    while (len! >= 102400) {
      len ~/= 1024;
      index++;
    }

    int integer = len ~/ 100;
    int decimal = len % 100;
    bool isNeedDecimal = integer == 0 && decimal == 0;

    return '$integer${isNeedDecimal ? '' : '.$decimal'}${suffix[index]}';
  }
}
