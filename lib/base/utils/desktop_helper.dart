import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

///
/// Created by a0010 on 2023/8/28 15:47
/// 桌面端工具类
class DesktopHelper {
  static Future<void> init() async {
    await windowManager.ensureInitialized();
    await setFixSize(
      size: const Size(400, 600),
      minimumSize: const Size(400, 600),
    );
  }

  /// 设置桌面端尺寸
  static Future<void> setFixSize({
    Size size = const Size(900, 680),
    Size minimumSize = const Size(900, 680),
  }) async {
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      //仅对桌面端进行尺寸设置
      WindowOptions windowOptions = WindowOptions(
        size: size,
        minimumSize: minimumSize,
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden, // 该属性隐藏导航栏
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
        await windowManager.setAsFrameless();
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
