import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/naughty/drag_layout.dart';
import 'package:flutter_ui/base/naughty/entities/http_entity.dart';
import 'package:flutter_ui/base/naughty/page/http/http_list_page.dart';
import 'package:flutter_ui/base/router/route_manager.dart';

/// 悬浮窗
class Naughty {
  Naughty._internal();

  static final Naughty getInstance = Naughty._internal();

  factory Naughty() => getInstance;

  Widget? _child;
  BuildContext? _context;

  OverlayEntry? _overlayEntry;

  List<HTTPEntity> data = [];

  /// 初始化, 设置子widget
  void init(BuildContext context, {Widget? child}) {
    this._context = context;
    this._child = child;
  }

  /// 显示悬浮窗
  void show() {
    dismiss();
    Future.delayed(Duration(milliseconds: 100), _create);
  }

  Future _create() async {
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) =>
          _child ??
          DragLayout(
            onTap: () => Navigation.push(HTTPListPage()),
            child: Container(
              alignment: Alignment.center,
              height: 64.0,
              width: 64.0,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                // 可以设置角度，BoxShape.circle 直接圆形
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
              ),
            ),
          ),
    );
    if (_context != null && _overlayEntry != null) {
      Overlay.of(_context!)?.insert(_overlayEntry!);
    }
  }

  /// 隐藏悬浮窗
  void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
