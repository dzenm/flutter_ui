import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

///
/// Created by a0010 on 2023/8/28 15:47
/// 桌面端工具类
class DesktopHelper {
  static Future<void> init() async {
    if (!isDesktop) return;

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
    if (!isDesktop) return;

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

  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
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

class DesktopGlobalBox extends StatelessWidget {
  const DesktopGlobalBox({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      // android伪全屏，加入边距
      padding: Platform.isAndroid ? const EdgeInsets.symmetric(horizontal: 374, vertical: 173) : EdgeInsets.zero,
      child: Container(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        margin: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          boxShadow: [
            BoxShadow(color: Color(0x33000000), blurRadius: 8),
          ],
        ),
        child: child,
      ),
    );
  }
}
