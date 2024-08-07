import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'window_button.dart';
import 'window_caption.dart';

/// 左上角的WindowsButton高度
const kWindowsButtonHeight = 24.0;
const kWindowsMoveBarHeight = 32.0;

///
/// Created by a0010 on 2023/8/28 15:47
/// 桌面包装器
class DesktopWrapper extends StatelessWidget {
  final Widget child;
  final double height;
  final bool showMoveBar;
  final bool isShowMinimize;
  final bool isShowMaximize;
  final bool isShowClose;

  const DesktopWrapper({
    super.key,
    required this.child,
    this.height = kWindowsMoveBarHeight,
    this.showMoveBar = true,
    this.isShowMinimize = true,
    this.isShowMaximize = true,
    this.isShowClose = true,
  });

  static Future<void> ensureInitialized() async {
    if (!_isDesktop) return;
    // 必须加上这一行。
    await windowManager.ensureInitialized();
    windowManager.setOpacity(0);
  }

  static Future<void> setWindow({
    Size size = const Size(900, 680),
    Size minimumSize = const Size(900, 680),
  }) async {
    if (!_isDesktop) return;

    //仅对桌面端进行尺寸设置
    WindowOptions windowOptions = WindowOptions(
      size: size,
      minimumSize: minimumSize,
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      title: '云鱼',
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: true,
    );
    windowManager.setOpacity(0);
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setBackgroundColor(Colors.transparent);
      await windowManager.show();
      await windowManager.focus();
      await windowManager.setOpacity(1.0);
    });
  }

  static bool get _isDesktop => !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  @override
  Widget build(BuildContext context) {
    if (!_isDesktop) return child;
    return Stack(alignment: Alignment.topRight, children: [
      child,
      WindowButtons(
        height: height,
        showMoveBar: showMoveBar,
        isShowMinimize: isShowMinimize,
        isShowMaximize: isShowMaximize,
        isShowClose: isShowClose,
      ),
    ]);
  }
}

/// 桌面窗口按钮
class WindowButtons extends StatelessWidget {
  final double? height;
  final MainAxisAlignment mainAxisAlignment;
  final bool showMoveBar;
  final bool isShowMinimize;
  final bool isShowMaximize;
  final bool isShowClose;

  const WindowButtons({
    super.key,
    this.height,
    this.mainAxisAlignment = MainAxisAlignment.end,
    this.showMoveBar = false,
    this.isShowMinimize = true,
    this.isShowMaximize = true,
    this.isShowClose = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget moveWindow = Expanded(child: SizedBox(height: height, child: const MoveWindow()));
    return Row(mainAxisAlignment: mainAxisAlignment, crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (showMoveBar && mainAxisAlignment == MainAxisAlignment.end) moveWindow,
      if (isShowMinimize) MinimizeWindowButton(),
      if (isShowMaximize) MaximizeWindowButton(),
      if (isShowClose) CloseWindowButton(),
      if (showMoveBar && mainAxisAlignment == MainAxisAlignment.start) moveWindow,
    ]);
  }
}

/// 桌面端全局大小圆角装饰的盒子
class AppBox extends StatelessWidget {
  const AppBox({
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
          BoxShadow(color: const Color(0x20000000), blurRadius: borderRadius),
        ],
      ),
      child: child,
    );
  }
}
