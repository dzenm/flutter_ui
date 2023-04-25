import 'package:flutter/foundation.dart';

///
/// Created by a0010 on 2023/2/10 15:16
///
class BuildConfig {
  /// 是否打印数据库日志
  static bool showDBLog = true;

  /// 是否打印HTTP请求日志
  static bool showHTTPLog = false;

  /// 是否打印Page中的生命周期日志
  static bool showPageLog = true;

  /// 是否进入测试APP
  static bool isTestApp = false;

  /// 中药请求key
  static String medicineKey = 'e5c1639a4fc97a080daaff94e08bd1ca';

  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android;

  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;

  static bool get isMac => defaultTargetPlatform == TargetPlatform.macOS;

  static bool get isLinux => defaultTargetPlatform == TargetPlatform.linux;

  static bool get isFuchsia => defaultTargetPlatform == TargetPlatform.fuchsia;

  static bool get isDesktop => isWindows || isMac || isLinux;

  static bool get isPhone => isAndroid || isIOS;

  static bool get isWeb => !(isDesktop && isPhone && isFuchsia);
}
