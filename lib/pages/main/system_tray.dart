import 'dart:async';
import 'dart:io';

import 'package:fbl/fbl.dart';
import 'package:tray_manager/tray_manager.dart';

///
/// Created by a0010 on 2023/12/6 15:28
///
mixin class SystemTray {
  static const String _iconNullWin = 'assets/images/null.ico';
  static const String _iconNullOther = 'assets/images/null.png';

  static final SystemTray _instance = SystemTray._internal();

  factory SystemTray() => _instance;

  SystemTray._internal();

  final TrayManager trayManager = TrayManager.instance;
  bool _showIcon = false; // 是否展示图标
  Timer? _timer; // 系统托盘闪烁计时器

  Future<void> init() async {
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
