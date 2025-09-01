import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

///
/// Created by a0010 on 2023/2/10 15:16
/// 构建时的参数
abstract class BuildConfig {
  BuildConfig._();

  static bool get isDebug => _isDebug;
  static const bool _isDebug = kDebugMode; // 是否是debug模式
  static bool get isTestApp => _isTestApp;
  static const bool _isTestApp = false; // 是否进入测试APP
  static bool get showDBLog => _showDBLog;
  static const bool _showDBLog = true; // 是否打印数据库日志
  static bool get showHTTPLog => _showHTTPLog;
  static const bool _showHTTPLog = false; // 是否打印HTTP请求日志
  static bool get showPageLog => _showPageLog;
  static const bool _showPageLog = true; // 是否打印Page中的生命周期日志

  static bool get isAndroid => defaultTargetPlatform == TargetPlatform.android; // 判断是否是Android平台
  static bool get isIOS => defaultTargetPlatform == TargetPlatform.iOS; // 判断是否是iOS平台
  static bool get isWindows => defaultTargetPlatform == TargetPlatform.windows; // 判断是否是Windows平台
  static bool get isMacOS => defaultTargetPlatform == TargetPlatform.macOS; // 判断是否是macOS平台
  static bool get isLinux => defaultTargetPlatform == TargetPlatform.linux; // 判断是否是Linux平台
  static bool get isFuchsia => defaultTargetPlatform == TargetPlatform.fuchsia; // 判断是否是Fuchsia平台
  static bool get isDesktop => isWindows || isMacOS || isLinux; // 判断是否是桌面端
  static bool get isMobile => isAndroid || isIOS; // 判断是否是移动端
  static bool get isWeb => kIsWeb && !(isDesktop || isMobile || isFuchsia); // 判断是否是Web端

  static bool _isInitialized = false; // 是否初始化 [packageInfo]
  static PackageInfo get packageInfo => _packageInfo;
  static late PackageInfo _packageInfo; // 包名相关的信息
  static AndroidDeviceInfo get androidDeviceInfo => _androidDeviceInfo;
  static late AndroidDeviceInfo _androidDeviceInfo; // Android设备相关的信息
  static IosDeviceInfo get iosDeviceInfo => _iosDeviceInfo;
  static late IosDeviceInfo _iosDeviceInfo; // iOS设备相关的信息

  /// 初始化设备/包名相关的信息
  static Future<void> init({bool needInitialized = true}) async {
    if (!needInitialized) return;
    if (_isInitialized) return;
    _isInitialized = true;
    _packageInfo = await PackageInfo.fromPlatform();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (isAndroid) {
      _androidDeviceInfo = await deviceInfo.androidInfo;
    } else if (isIOS) {
      _iosDeviceInfo = await deviceInfo.iosInfo;
    }
  }

  /// 获取APP信息
  static Map<String, dynamic> getPackageInfo() {
    if (!_isInitialized) return {};
    PackageInfo info = _packageInfo;
    return {
      'appName': info.appName,
      'packageName': info.packageName,
      'version': info.version,
      'buildNumber': info.buildNumber,
      'buildSignature': info.buildSignature,
    };
  }

  /// 获取设备信息
  static Map<String, dynamic> getDeviceInfo() {
    if (!_isInitialized) return {};
    Map<String, dynamic> map = {};
    if (isAndroid) {
      AndroidDeviceInfo info = _androidDeviceInfo;
      Map<String, dynamic> temp = {
        'baseOS': info.version.baseOS,
        'codename': info.version.codename,
        'incremental': info.version.incremental,
        'previewSdkInt': info.version.previewSdkInt,
        'release': info.version.release,
        'sdkInt': info.version.sdkInt,
        'securityPatch': info.version.securityPatch,
      };
      map.addAll(temp);
      map.addAll(info.data);
      map.remove('version');
    } else if (isIOS) {
      IosDeviceInfo info = _iosDeviceInfo;
      Map<String, dynamic> temp = {
        'sysname': info.utsname.sysname,
        'nodename': info.utsname.nodename,
        'release': info.utsname.release,
        'version': info.utsname.version,
        'machine': info.utsname.machine,
      };
      map.addAll(temp);
      map.addAll(info.data);
      map.remove('utsname');
    }
    return map;
  }
}
