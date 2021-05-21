import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/http/log.dart';

import 'drag_layout.dart';
import 'page/home/home_page.dart';

/// 悬浮窗
class Naughty {
  Naughty._internal();

  static final Naughty instance = Naughty._internal();

  factory Naughty() => instance;

  Widget? _child;
  BuildContext? _context;

  OverlayEntry? _overlayEntry;

  /// 初始化, 设置子widget
  void init(BuildContext context, {Widget? child}) {
    this._context = context;
    this._child = child;
    Log.d('初始化悬浮窗: context=$_context, child=$_child');
  }

  /// 显示悬浮窗
  void show() {
    dismiss();
    Log.d('显示悬浮窗');
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) =>
          _child ??
          DragLayout(
            onTap: () => Navigator.of(context).pushNamed(HOME_ROUTE),
            child: Container(
              alignment: Alignment.center,
              height: 64.0,
              width: 64.0,
              child: Text('悬浮窗', style: TextStyle(fontSize: 14)),
              decoration: BoxDecoration(
                color: Colors.blue, shape: BoxShape.circle, // 可以设置角度，BoxShape.circle 直接圆形
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
            ),
          ),
    );
    Overlay.of(_context!)!.insert(_overlayEntry!);
  }

  /// 隐藏悬浮窗
  void dismiss() {
    Log.d('隐藏悬浮窗');
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
