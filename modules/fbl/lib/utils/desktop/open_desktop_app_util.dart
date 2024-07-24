import 'dart:io';

import 'package:flutter/foundation.dart';

///
/// Created by a0010 on 2024/3/20 14:54
///
class OpenDesktopAppUtil {
  /// 使用系统文件夹打开文件路径所在的文件夹
  static Future openInExplorer(String path) async {
    try {
      // 根据桌面端类型区分命令行工具
      String? execute;
      List<String> arguments = [];
      if (Platform.isWindows) {
        execute = 'explorer';
        arguments = ['-o', path];
      } else if (Platform.isMacOS) {
        execute = 'open';
        arguments = ['-R', path];
      } else if (Platform.isLinux) {
        execute = 'open';
        arguments = ['-R', path];
      }
      if (execute == null) return;
      await Process.run(
        execute,
        arguments,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// 使用系统文件夹打开文件路径所在的文件夹
  static Future openPdf(String path) async {
    try {
      // 根据桌面端类型区分命令行工具
      String? execute;
      List<String> arguments = [];
      if (Platform.isWindows) {
        execute = 'start';
        arguments = [path];
      } else if (Platform.isMacOS) {
        execute = 'open';
        arguments = [path];
      } else if (Platform.isLinux) {
        execute = 'open';
        arguments = [path];
      }
      if (execute == null) return;
      await Process.run(
        execute,
        arguments,
        runInShell: true,
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
