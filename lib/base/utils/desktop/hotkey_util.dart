import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

///
/// Created by a0010 on 2024/4/7 11:43
/// 快捷键工具
class HotkeyUtil {
  static final HotkeyUtil _instance = HotkeyUtil._internal();
  static HotkeyUtil get instance => _instance;
  factory HotkeyUtil() => instance;
  HotkeyUtil._internal();

  Function? _logPrint;

  Future<void> init({Function? logPrint}) async {
    _logPrint = logPrint;
    await register();
  }

  Future<void> register() async {
    if (Platform.isAndroid || Platform.isIOS || kIsWeb) return;
    HotKey hotKey = HotKey(
      key: PhysicalKeyboardKey.keyQ,
      modifiers: [HotKeyModifier.alt],
      // Set hotkey scope (default is HotKeyScope.system)
      scope: HotKeyScope.inapp, // Set as in app-wide hotkey.
    );
    await hotKeyManager.register(
      hotKey,
      keyDownHandler: (hotKey) {
        log('onKeyDown+${hotKey.toJson()}');
      },
      // Only works on macOS.
      keyUpHandler: (hotKey) {
        log('onKeyUp+${hotKey.toJson()}');
      },
    );

    // For hot reload, `unregisterAll()` needs to be called.
    // await hotKeyManager.unregisterAll();
  }

  void log(String msg) => _logPrint == null ? null : _logPrint!(msg, tag: 'HotkeyUtil');
}
