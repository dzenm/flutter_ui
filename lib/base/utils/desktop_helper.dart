import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

///
/// Created by a0010 on 2023/8/28 15:47
/// 桌面端工具类
class DesktopHelper {
  /// 设置桌面端尺寸
  static Future<void> setFixSize({Size size = const Size(800, 600)}) async {
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      //仅对桌面端进行尺寸设置
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = const WindowOptions(
        size: Size(900, 680),
        minimumSize: Size(900, 680),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.setTitleBarStyle(TitleBarStyle.hidden, windowButtonVisibility: false);
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }
}

class DragToMoveAreaNoDouble extends StatelessWidget {
  final Widget child;

  const DragToMoveAreaNoDouble({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        windowManager.startDragging();
      },
      child: child,
    );
  }
}
