import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../res/assets.dart';
import '../router/route_manager.dart';
import '../widgets/floating_button.dart';
import 'entities/http_entity.dart';
import 'page/http/http_list_page.dart';

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
            FloatingButton(
              onTap: () => RouteManager.push(HTTPListPage()),
              imageProvider: AssetImage(Assets.image(('ic_vnote.png'))),
            ) // DragLayout(
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
