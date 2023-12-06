import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/8/28 15:47
/// 桌面端工具类
class DesktopHelper {
  static Future<void> init({
    Size size = const Size(900, 680),
    Size minimumSize = const Size(900, 680),
  }) async {
    if (!isDesktop) return;

    doWhenWindowReady(() {
      //仅对桌面端进行尺寸设置
      final windows = appWindow;
      windows.minSize = minimumSize;
      windows.size = size;
      windows.alignment = Alignment.center;
      windows.title = '云鱼';
      windows.show();
    });
  }

  static bool get isDesktop => Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}

class DesktopGlobalBox extends StatelessWidget {
  const DesktopGlobalBox({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid || Platform.isIOS) {
      return child;
    }
    return Container(
      width: double.infinity,
      height: double.infinity,
      // android伪全屏，加入边距
      padding: Platform.isAndroid ? const EdgeInsets.symmetric(horizontal: 374, vertical: 173) : EdgeInsets.zero,
      child: Container(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          boxShadow: [
            BoxShadow(color: Color(0x33000000), blurRadius: 8),
          ],
        ),
        child: WindowBorder(
          color: const Color(0xFFF6A00C),
          width: 1,
          child: child,
        ),
      ),
    );
  }
}

class LeftSide extends StatelessWidget {
  static const sidebarColor = Color(0xFFF6A00C);

  const LeftSide({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Container(
        color: sidebarColor,
        child: Column(
          children: [
            WindowTitleBarBox(child: MoveWindow()),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }
}

class RightSide extends StatelessWidget {
  static const backgroundStartColor = Color(0xFFFFD500);
  static const backgroundEndColor = Color(0xFFF6A00C);
  static const borderColor = Color(0xFF805306);

  const RightSide({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [backgroundStartColor, backgroundEndColor],
            stops: [0.0, 1.0],
          ),
        ),
        child: Column(children: [
          WindowTitleBarBox(
            child: Row(children: [
              Expanded(child: MoveWindow()),
              const WindowButtons(),
            ]),
          )
        ]),
      ),
    );
  }
}

/// 桌面
class WindowWrapper extends StatelessWidget {
  final Widget child;
  final bool showTitleBar;

  const WindowWrapper({
    super.key,
    required this.child,
    this.showTitleBar = false,
  });

  @override
  Widget build(BuildContext context) {
    if (showTitleBar) {
      return WindowBorder(
        color: Colors.white,
        width: 1,
        child: Column(children: [
          WindowTitleBarBox(
            child: Row(children: [
              Expanded(child: MoveWindow()),
              const WindowButtons(),
            ]),
          ),
          child,
        ],),
      );
    }
    return WindowBorder(
      color: Colors.white,
      width: 1,
      child: Stack(alignment: Alignment.topRight, children: [
        child,
        const WindowButtons(),
      ],),
    );
  }
}

class WindowButtons extends StatelessWidget {
  static final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF805306),
    mouseOver: const Color(0xFFF6A00C),
    mouseDown: const Color(0xFF805306),
    iconMouseOver: const Color(0xFF805306),
    iconMouseDown: const Color(0xFFFFD500),
  );

  static final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white,
  );

  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      MinimizeWindowButton(colors: buttonColors),
      MaximizeWindowButton(colors: buttonColors),
      CloseWindowButton(colors: closeButtonColors),
    ]);
  }
}
