import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

///
/// Created by a0010 on 2023/2/10 15:16
///
class BuildConfig {
  /// 是否是debug模式
  static bool isDebug = kDebugMode;

  /// 是否进入测试APP
  static bool isTestApp = true;

  /// 是否打印数据库日志
  static bool showDBLog = true;

  /// 是否打印HTTP请求日志
  static bool showHTTPLog = false;

  /// 是否打印Page中的生命周期日志
  static bool showPageLog = true;

  /// 判断是否是Android平台
  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  /// 判断是否是iOS平台
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  /// 判断是否是Windows平台
  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;

  /// 判断是否是macOS平台
  static bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS;

  /// 判断是否是Linux平台
  static bool get isLinux => defaultTargetPlatform == TargetPlatform.linux;

  /// 判断是否是Fuchsia平台
  static bool get isFuchsia => defaultTargetPlatform == TargetPlatform.fuchsia;

  /// 判断是否是桌面端
  static bool get isDesktop => isWindows || isMacOS || isLinux;

  /// 判断是否是移动端
  static bool get isMobile => isAndroid || isIOS;

  /// 判断是否是Web端
  static bool get isWeb => kIsWeb && !(isDesktop || isMobile || isFuchsia);

  /// 是否初始化 [packageInfo]
  static bool isInitialized = false;

  /// 包名相关的信息
  static late PackageInfo packageInfo;

  /// Android设备相关的信息
  static late AndroidDeviceInfo androidDeviceInfo;

  /// iOS设备相关的信息
  static late IosDeviceInfo iosDeviceInfo;

  /// 初始化设备/包名相关的信息
  static Future<void> init({bool needInitialized = true}) async {
    if (!needInitialized) return;
    if (isInitialized) return;
    isInitialized = true;
    packageInfo = await PackageInfo.fromPlatform();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (BuildConfig.isAndroid) {
      androidDeviceInfo = await deviceInfo.androidInfo;
    } else if (BuildConfig.isIOS) {
      iosDeviceInfo = await deviceInfo.iosInfo;
    }
  }
}
