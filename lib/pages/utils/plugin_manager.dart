import 'dart:io';

import 'package:fbl/fbl.dart';
import 'package:flutter/services.dart';

///
/// Created by a0010 on 2023/8/16 15:10
///
class PluginManager {
  static const MethodChannel _channel = MethodChannel('flutter_ui/channel/');
  static const String _methodBackToDesktop = 'backToDesktop';
  static const String _methodInstallAPK = 'installAPK';

  /// 点击返回键回退到手机桌面
  static Future<bool> backToDesktop() async {
    if (!Platform.isAndroid) return false;
    try {
      // 通知安卓返回,到手机桌面
      bool out = await _channel.invokeMethod(_methodBackToDesktop);
      return out;
    } on PlatformException catch (e) {
      Log.e(e.message);
    }
    return false;
  }

  /// 根据文件路径安装APK
  static Future<bool> installAPK(String filePath) async {
    if (!Platform.isAndroid) return false;
    try {
      // APK文件路径
      Map<String, dynamic> inData = {'filePath': filePath};
      String outData = await _channel.invokeMethod(_methodInstallAPK, inData);
      Log.d('安装APK: outData=$outData, inData=$inData');
      return true;
    } on PlatformException catch (e) {
      Log.e(e.message);
    }
    return false;
  }
}
