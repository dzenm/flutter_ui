import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/util.dart';
import 'floating_button.dart';
import 'http_entity.dart';
import 'naught_page.dart';

/// 悬浮窗
class Naughty {
  Naughty._internal();

  static final Naughty _instance = Naughty._internal();

  static Naughty get instance => _instance;

  factory Naughty() => _instance;

  BuildContext? _context;

  BuildContext get context => _context!;

  /// 悬浮窗创建的控制器
  OverlayEntry? _overlayEntry;

  List<HTTPEntity> httpRequests = [];

  bool _showing = false;

  bool get showing => _showing;

  bool get _isInit => _context != null && !kIsWeb;

  /// 初始化, 设置子widget
  void init(BuildContext context, {Widget? child}) {
    if (_isInit) return;
    _context = context;
    // 创建悬浮窗
    _overlayEntry ??= OverlayEntry(builder: (BuildContext context) {
      // 自定义悬浮窗布局
      return child ??
          FloatingButton(
            onTap: () => push(context, const NaughtPage()),
            imageProvider: const AssetImage('assets/images/ic_vnote.png'),
          );
    });
  }

  /// 关闭并且恢复到初始状态
  void dispose() {
    if (!_isInit) return;
    _context = null;
    _showing = false;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// 显示悬浮窗
  void show() {
    if (!_isInit || _showing) return;
    _showing = true;

    /// TODO 重复点击显示悬浮窗退出悬浮窗会报错，暂时未找的解决的办法
    /// Failed assertion: line 1956 pos 12: '_elements.contains(element)': is not true.
    Future.delayed(Duration.zero, () {
      if (_context == null || _overlayEntry == null) return;
      Overlay.of(_context!).insert(_overlayEntry!);
    });
  }

  /// 隐藏悬浮窗
  void dismiss() {
    if (!_isInit || !_showing) return;
    _showing = false;
    _overlayEntry?.remove();
  }

  /// 展示通知
  void showNotification({String? title, String? body}) {
    if (!_isInit) return;
    NotificationUtil().showNotification(
      title: title,
      body: body,
      onTap: (payload) async => push(context, const NaughtPage()),
    );
  }

  /// 打开一个新的页面
  void push(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => page,
        settings: RouteSettings(name: page.toStringShort()),
      ),
    );
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
    return path.split(Platform.pathSeparator).last;
  }

  /// 格式化字节大小，例：
  /// len  = 2889728
  /// size = 2.88 MB
  String formatByteSize(int? len) {
    // 小于1024，直接按字节显示
    if (len == null) return '0 B';
    int multiple = 1024; // 字节的倍数
    if (len < multiple) return '$len B';

    List<String> suffix = ["B", "KB", "MB", "GB", "TB", "PB"];
    // 判断字节显示的范围，从KB开始
    int scope = multiple, i = 1;
    for (; i < suffix.length; i++) {
      if (len < scope * multiple) break; //找到范围 scope < len < scope * multiple
      scope *= multiple;
    }

    double res = len / scope; // 得到最终展示的小数
    return '${toStringAsFixed(res)} ${suffix[i]}';
  }

  String toStringAsFixed(dynamic value, {int position = 2}) {
    double num;
    if (value is double) {
      num = value;
    } else {
      num = double.parse(value.toString());
    }

    int index = num.toString().lastIndexOf(".");
    String res;
    if ((num.toString().length - index - 1) < position) {
      res = num.toStringAsFixed(position);
    } else {
      res = num.toString();
    }
    return res.substring(0, index + position + 1).toString();
  }
}
