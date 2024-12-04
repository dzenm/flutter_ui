import 'dart:async';
import 'dart:io';

import 'package:dbl/dbl.dart';
import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/application.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

///
/// Created by a0010 on 2024/12/3 16:25
/// 桌面端相关的服务
class DesktopService with Logging, TrayMixin implements WindowListener, TrayListener {
  static final DesktopService _instance = DesktopService._internal();
  factory DesktopService() => _instance;
  DesktopService._internal();

  void register() {
    logPage('initState');

    // 这里注意一个问题，在桌面端可能会存在多个StatefulWidget在一个页面，导致数据变化的时候，没有重建子StatefulWidget，而是直接调用旧的build方法，
    // 所以会出现initState未执行的情况，这种问题的解决办法是在didUpdateWidget进行判断oldWidget与widget是否相同，将initState应该执行的内容再次执行即可

    windowManager.addListener(this);
    trayManager.addListener(this);

    DesktopWrapper.setWindow();
    initTray();
  }

  void unregister() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    logPage('dispose');
  }

  /// TrayManager listener
  @override
  void onTrayIconMouseDown() {
    logInfo('onTrayIconMouseDown');

    // 图标鼠标左键单击事件（显示程序）
    final windows = windowManager;
    windows.restore();
  }

  @override
  void onTrayIconMouseUp() {}

  @override
  void onTrayIconRightMouseDown() {
    logInfo('onTrayIconRightMouseDown');

    // 图标鼠标右键单击事件（显示菜单）
    TrayMixin().trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseUp() {}

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    logInfo('onTrayMenuItemClick');

    // 菜单选项点击事件
    switch (menuItem.key) {
      case 'exit':
        final windows = windowManager;
        windows.close();
        break;
    }
  }

  /// WindowsManager listener
  @override
  void onWindowClose() async {
    // do something
    bool isPreventClose = await windowManager.isPreventClose();
    if (isPreventClose) {
      BuildContext context = Application().context;
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text('Are you sure you want to close this window?'),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await windowManager.destroy();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void onWindowFocus() {
    // 窗口获取焦点后调用
    // Make sure to call once.
    // setState(() {});
    // do something
  }

  @override
  void onWindowBlur() {
    // 窗口失去焦点后调用
    // do something
  }

  @override
  void onWindowMaximize() {
    //
    // do something
  }

  @override
  void onWindowUnmaximize() {
    // do something
  }

  @override
  void onWindowMinimize() {
    // 最小化窗口时调用
    // do something
  }

  @override
  void onWindowRestore() {
    // 最大化恢复窗口时调用
    // do something
  }

  @override
  void onWindowResize() {
    // 窗口尺寸准备发生变化时调用（调整窗口大小/最大化）
    // do something
  }

  @override
  void onWindowResized() {
    // 窗口尺寸正在发生变化时调用（调整窗口大小/最大化）
    // do something
  }

  @override
  void onWindowMove() {
    // 窗口准备移动时调用
    // do something
  }

  @override
  void onWindowMoved() {
    // 窗口正在移动时调用
    // do something
  }

  @override
  void onWindowEnterFullScreen() {
    // 进入全屏时调用（最大化屏幕）
    // do something
  }

  @override
  void onWindowLeaveFullScreen() {
    // 离开全屏时调用（最大化恢复）
    // do something
  }

  @override
  void onWindowDocked() {}

  @override
  void onWindowUndocked() {}

  @override
  void onWindowEvent(String eventName) {
    logPage('onWindowEvent: eventName=$eventName');
  }
}

mixin class TrayMixin {
  static const String _iconNullWin = 'assets/images/null.ico';
  static const String _iconNullOther = 'assets/images/null.png';

  final TrayManager trayManager = TrayManager.instance;
  bool _showIcon = false; // 是否展示图标
  Timer? _timer; // 系统托盘闪烁计时器

  Future<void> initTray() async {
    _generateIcon();
    Menu menu = Menu(items: [
      MenuItem(key: 'exit', label: '退出'),
      // MenuItem(label: '数学', toolTip: '躲不掉的'),
      // MenuItem.checkbox(
      //   label: '英语',
      //   checked: true,
      //   onClick: (menuItem) {
      //     menuItem.checked = !(menuItem.checked == true);
      //   },
      // ),
      // MenuItem.separator(),
      // MenuItem.submenu(
      //   key: 'science',
      //   label: '理科',
      //   submenu: Menu(items: [
      //     MenuItem(label: '物理'),
      //     MenuItem(label: '化学'),
      //     MenuItem(label: '生物'),
      //   ]),
      // ),
      // MenuItem.separator(),
      // MenuItem.submenu(
      //   key: 'arts',
      //   label: '文科',
      //   submenu: Menu(items: [
      //     MenuItem(label: '政治'),
      //     MenuItem(label: '历史'),
      //     MenuItem(label: '地理'),
      //   ]),
      // ),
    ]);
    await trayManager.setContextMenu(menu);
  }

  /// 生成图标
  void _generateIcon() async {
    String path = Platform.isWindows ? Assets.windowsSystemDrayIcons : Assets.maxOSSystemDrayIcons;
    await trayManager.setIcon(path);
    _showIcon = true;
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  void startFlash() {
    if (_showIcon) {
      _closeIconFlash();
    } else {
      _openIconFlash();
    }
  }

  /// 开启系统托盘闪烁效果
  void _openIconFlash() {
    _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) async {
      if (_showIcon) {
        await trayManager.setIcon(Platform.isWindows ? _iconNullWin : _iconNullOther);
      } else {
        String path = Platform.isWindows ? Assets.windowsSystemDrayIcons : Assets.maxOSSystemDrayIcons;
        await trayManager.setIcon(path);
      }
      _showIcon = !_showIcon;
    });
  }

  /// 关闭系统托盘闪烁效果
  void _closeIconFlash() {
    _timer?.cancel();
    _generateIcon();
  }
}
