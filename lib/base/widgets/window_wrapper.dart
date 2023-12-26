import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/8/28 15:47
/// 桌面包装器
class WindowWrapper extends StatelessWidget {
  final Widget child;
  final double height;
  final bool showMoveBar;
  final bool isShowMinimize;
  final bool isShowMaximize;
  final bool isShowClose;

  const WindowWrapper({
    super.key,
    required this.child,
    this.height = 30,
    this.showMoveBar = true,
    this.isShowMinimize = true,
    this.isShowMaximize = true,
    this.isShowClose = true,
  });

  static Future<void> setWindow({
    Size size = const Size(900, 680),
    Size minimumSize = const Size(900, 680),
  }) async {
    if (!_isDesktop) return;

    doWhenWindowReady(() {
      //仅对桌面端进行尺寸设置
      final windows = appWindow;
      windows.minSize = minimumSize;
      windows.size = size;
      windows.title = '云鱼';
      windows.show();
    });
  }

  static bool get _isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  @override
  Widget build(BuildContext context) {
    if (!_isDesktop) return child;
    return WindowBorder(
      color: Colors.white,
      width: 0.1,
      child: Stack(alignment: Alignment.topRight, children: [
        child,
        WindowButtons(
          height: height,
          showMoveBar: showMoveBar,
          isShowMinimize: isShowMinimize,
          isShowMaximize: isShowMaximize,
          isShowClose: isShowClose,
        ),
      ]),
    );
  }
}

/// 桌面窗口按钮
class WindowButtons extends StatelessWidget {
  static final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF805306),
    mouseOver: const Color(0xFFF6A00C),
    mouseDown: const Color(0xFF805306),
    iconMouseOver: Colors.white,
    iconMouseDown: const Color(0xFFFFD500),
  );

  static final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white,
  );

  final double height;
  final MainAxisAlignment mainAxisAlignment;
  final bool showMoveBar;
  final bool isShowMinimize;
  final bool isShowMaximize;
  final bool isShowClose;

  const WindowButtons({
    super.key,
    this.height = 30,
    this.mainAxisAlignment = MainAxisAlignment.end,
    this.showMoveBar = false,
    this.isShowMinimize = true,
    this.isShowMaximize = true,
    this.isShowClose = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget moveWindow = Expanded(child: SizedBox(height: height, child: MoveWindow()));
    return Row(mainAxisAlignment: mainAxisAlignment, crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (showMoveBar && mainAxisAlignment == MainAxisAlignment.end) moveWindow,
      if (isShowMinimize) MinimizeWindowButton(colors: buttonColors),
      if (isShowMaximize) MaximizeWindowButton(colors: buttonColors),
      if (isShowMinimize) CloseWindowButton(colors: closeButtonColors),
      if (isShowClose && mainAxisAlignment == MainAxisAlignment.start) moveWindow,
    ]);
  }
}

/// 桌面端全局大小设置
class GlobalBox extends StatelessWidget {
  const GlobalBox({
    super.key,
    required this.child,
    this.borderRadius = 8,
  });

  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      return child;
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        boxShadow: [
          BoxShadow(color: const Color(0x22000000), blurRadius: borderRadius),
        ],
      ),
      child: WindowBorder(
        color: Colors.white,
        width: 0.1,
        child: child,
      ),
    );
  }
}