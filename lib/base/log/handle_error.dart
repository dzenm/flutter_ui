import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/utils/file_util.dart';
import 'package:package_info/package_info.dart';

/// 启动flutter APP
typedef StartFlutterAPP = void Function();

/// 处理字符串
typedef HandleMsg = void Function(String msg);

/// 全局处理错误信息
///
/// 在pubspec.yaml添加下列依赖
/// # 获取硬件设备信息
//  device_info: ^0.4.0+1
//  # 获取APP相关信息
//  package_info: ^0.4.0+2
class HandleError {
  // 私有构造方法
  HandleError._internal();

  static final HandleError getInstance = HandleError._internal();

  factory HandleError() => getInstance;

  static const String crashParent = 'crash';

  // 捕获flutter运行时的错误
  // await HandleError().catchFlutterError(() => runApp(_initPage()));
  Future catchFlutterError(StartFlutterAPP startFlutterAPP, {String? fileName, HandleMsg? handleMsg}) async {
    if (!kReleaseMode) {
      FlutterError.onError = (FlutterErrorDetails details) async {
        if (details.stack != null) {
          Zone.current.handleUncaughtError(details.exception, details.stack!);
        }
      };
    }
    // 自定义错误界面
    // ErrorWidget.builder = (FlutterErrorDetails details) {
    //   return Scaffold(
    //     body: Center(
    //       child: Container(
    //         padding: EdgeInsets.all(64),
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             Icon(Icons.error, color: Colors.red, size: 64),
    //             Text(
    //               details.exceptionAsString(),
    //               style: TextStyle(color: Colors.red, fontSize: 14),
    //             )
    //           ],
    //         ),
    //       ),
    //     ),
    //   );
    // };

    runZonedGuarded<Future<void>>(() async {
      Log.d('╔════════════════════════════════════════════════════════════════════════════╗');
      Log.d('║                                                                            ║');
      Log.d('║                Start Flutter APP                                           ║');
      Log.d('║                                                                            ║');
      Log.d('╚════════════════════════════════════════════════════════════════════════════╝');
      startFlutterAPP();
    }, (dynamic error, StackTrace stackTrace) async {
      Log.e('╔════════════════════════════════════════════════════════════════════════════╗');
      Log.e('║                                                                            ║');
      Log.e('║                Handle Flutter Error                                        ║');
      Log.e('║                                                                            ║');
      Log.e('╚════════════════════════════════════════════════════════════════════════════╝');

      String msg = await _handleErrorConvertText(error, stackTrace);
      // 保存为文件
      fileName = fileName ?? 'crash_${DateTime.now()}.log';
      await FileUtil.getInstance.save(fileName!, msg, dir: crashParent).then((value) async {
        if (value) {
          // 处理文件
          Directory dir = await FileUtil.getInstance.getParent(dir: crashParent);
          File file = File('${dir.path}/$fileName');
          if (handleMsg != null) {
            handleMsg(file.path);
          }
        }
      });
    });
  }

  // 处理错误转化为文本信息
  Future<String> _handleErrorConvertText(dynamic error, StackTrace stackTrace) async {
    StringBuffer sb = new StringBuffer();
    await _handleInfo(error, stackTrace, (msg) {
      // 打印在控制台
      Log.e('║$interval$msg');
      // 转化为文本
      sb.write('$msg\n');
    });
    return sb.toString();
  }

  // 收集信息
  Future<Null> _handleInfo(dynamic error, StackTrace stackTrace, HandleMsg handleMsg) async {
    // APP信息
    PackageInfo info = await PackageInfo.fromPlatform();
    Map<String, dynamic> appInfo = _appInfo(info);

    // 设备信息
    Map<String, dynamic>? deviceInfo;
    DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await infoPlugin.androidInfo;
      deviceInfo = _androidInfo(info);
    } else if (Platform.isIOS) {
      IosDeviceInfo info = await infoPlugin.iosInfo;
      deviceInfo = _iOSInfo(info);
    }

    // 处理手机信息
    Log.e('╔══════════════════════════════ Phone Info ══════════════════════════════════╗');
    handleMsg('APP Info');
    appInfo.forEach((key, value) => handleMsg('$interval$key: $value'));
    handleMsg('Device Info');
    deviceInfo?.forEach((key, value) => handleMsg('$interval$key: $value'));
    Log.e('╚════════════════════════════════════════════════════════════════════════════╝');

    // 处理异常信息
    handleMsg('\n');
    handleMsg('$error');
    handleMsg('\n');

    Log.e('╔══════════════════════════════ Error Info ══════════════════════════════════╗');
    // 处理异常信息栈
    List<String> list = stackTrace.toString().split('\n');
    for (int i = 0; i < list.length; i++) {
      if (list[i].contains('dart:async/zone.dart') ||
          list[i].contains('package:flutter/src/rendering/binding.dart') ||
          list[i].contains('package:flutter/src/widgets/framework.dart')) {
        break;
      }
      handleMsg('${list[i]}');
    }
    Log.e('╚════════════════════════════════════════════════════════════════════════════╝');
  }

  // APP信息
  Map<String, dynamic> _appInfo(PackageInfo info) => {
        'appName': info.appName, // APP名称
        'packageName': info.packageName, // 包名
        'version': info.version, // 版本名
        'buildNumber': info.buildNumber, // 版本号
      };

  // 安卓设备信息
  Map<String, dynamic> _androidInfo(AndroidDeviceInfo info) => {
        'version.securityPatch': info.version.securityPatch,
        'version.sdkInt': info.version.sdkInt,
        'version.release': info.version.release,
        'version.previewSdkInt': info.version.previewSdkInt,
        'version.incremental': info.version.incremental,
        'version.codename': info.version.codename,
        'version.baseOS': info.version.baseOS,
        'board': info.board,
        'bootloader': info.bootloader,
        'brand': info.brand,
        'device': info.device,
        'display': info.display,
        'fingerprint': info.fingerprint,
        'hardware': info.hardware,
        'host': info.host,
        'id': info.id,
        'manufacturer': info.manufacturer,
        'model': info.model,
        'product': info.product,
        'supported32BitAbis': info.supported32BitAbis,
        'supported64BitAbis': info.supported64BitAbis,
        'supportedAbis': info.supportedAbis,
        'tags': info.tags,
        'type': info.type,
        'isPhysicalDevice': info.isPhysicalDevice,
        'androidId': info.androidId
      };

  // iOS设备信息
  Map<String, dynamic> _iOSInfo(IosDeviceInfo info) => {
        'name': info.name,
        'systemName': info.systemName,
        'systemVersion': info.systemVersion,
        'model': info.model,
        'localizedModel': info.localizedModel,
        'identifierForVendor': info.identifierForVendor,
        'isPhysicalDevice': info.isPhysicalDevice,
        'utsname.sysname:': info.utsname.sysname,
        'utsname.nodename:': info.utsname.nodename,
        'utsname.release:': info.utsname.release,
        'utsname.version:': info.utsname.version,
        'utsname.machine:': info.utsname.machine,
      };
}
