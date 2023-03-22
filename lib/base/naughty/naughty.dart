import 'package:flutter/material.dart';

import '../res/assets.dart';
import '../router/route_manager.dart';
import '../widgets/floating_button.dart';
import 'http/http_list_page.dart';
import 'http_entity.dart';

/// 悬浮窗
/// TODO import
class Naughty {
  Naughty._internal();

  static final Naughty instance = Naughty._internal();

  factory Naughty() => instance;

  Widget? _child;
  BuildContext? _context;

  BuildContext get context => _context!;

  OverlayEntry? _overlayEntry;

  List<HTTPEntity> data = [];

  /// 初始化, 设置子widget
  void init(BuildContext context, {Widget? child}) {
    _context = context;
    _child = child;
  }

  Future<void> _createOverlay() async {
    _overlayEntry ??= OverlayEntry(builder: (BuildContext context) {
        return _child ??
            FloatingButton(
              onTap: () => RouteManager.push(context, const HTTPListPage()),
              imageProvider: AssetImage(Assets.image(('ic_vnote.png'))),
            );
      });
    if (_context != null) {
      Overlay.of(_context!)?.insert(_overlayEntry!);
    }
  }

  /// 显示悬浮窗
  void show() {
    dismiss();
    Future.delayed(const Duration(milliseconds: 100), _createOverlay);
  }

  /// 隐藏悬浮窗
  void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
