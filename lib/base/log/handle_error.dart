import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/utils/file_util.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 启动flutter APP
typedef RunFlutterAPP = void Function();

/// 处理字符串
typedef HandleMsg = void Function(String msg);

///
/// Created by a0010 on 2022/3/22 09:38
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
  Future catchFlutterError(RunFlutterAPP runFlutterAPP, {String? fileName, HandleMsg? handleMsg}) async {
    if (true) {
      // debug模式下进行异常捕获并输出
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
      // 在这里启动Flutter APP之后，所有的异常信息才能捕获成功
      Log.d('╔════════════════════════════════════════════════════════════════════════════╗');
      Log.d('║                                                                            ║');
      Log.d('║                Start Flutter APP                                           ║');
      Log.d('║                                                                            ║');
      Log.d('╚════════════════════════════════════════════════════════════════════════════╝');
      runFlutterAPP();
    }, (dynamic error, StackTrace stackTrace) async {
      // 出现异常后，在这里处理异常
      Log.e('╔════════════════════════════════════════════════════════════════════════════╗');
      Log.e('║                                                                            ║');
      Log.e('║                Handle Flutter Error                                        ║');
      Log.e('║                                                                            ║');
      Log.e('╚════════════════════════════════════════════════════════════════════════════╝');

      String msg = await _convertErrorToText(error, stackTrace);
      // 保存为文件
      fileName = fileName ?? 'crash_${DateTime.now()}.log';
      await FileUtil.getInstance.save(fileName!, msg, dir: crashParent).then((String? filePath) async {
        if (filePath != null && handleMsg != null) {
          // 处理文件
          handleMsg(filePath);
        }
      });
    });
  }

  // 处理错误转化为文本信息
  Future<String> _convertErrorToText(dynamic error, StackTrace stackTrace) async {
    StringBuffer sb = StringBuffer();
    await _collectInfo(error, stackTrace, (msg) {
      // 打印在控制台
      Log.e('║$interval$msg');
      // 转化为文本
      sb.write('$msg\n');
    });
    return sb.toString();
  }

  // 收集信息
  Future<void> _collectInfo(dynamic error, StackTrace stackTrace, HandleMsg handleMsg) async {
    // APP信息
    PackageInfo info = await PackageInfo.fromPlatform();
    Map<String, dynamic> appInfo = {
      'appName': info.appName,
      'packageName': info.packageName,
      'version': info.version,
      'buildNumber': info.buildNumber,
      'buildSignature': info.buildSignature,
    };

    // 设备信息
    Map<String, dynamic>? deviceInfo;
    DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await infoPlugin.androidInfo;
      deviceInfo = info.toMap();
    } else if (Platform.isIOS) {
      IosDeviceInfo info = await infoPlugin.iosInfo;
      deviceInfo = info.toMap();
    }

    // 处理APP和设备信息
    Log.e('╔══════════════════════════════ Phone Info ══════════════════════════════════╗');
    handleMsg('APP Info');
    appInfo.forEach((key, value) => handleMsg('$key: $value'));
    handleMsg('Device Info');
    deviceInfo?.forEach((key, value) => handleMsg('$key: $value'));

    // 处理异常信息
    Log.e('║══════════════════════════════ Error Info ═══════════════════════════════════');
    handleMsg('\n');
    handleMsg('$interval$error');
    handleMsg('\n');

    // 处理异常信息栈
    Log.e('║══════════════════════════════ Stack Trace ══════════════════════════════════');
    List<String> list = stackTrace.toString().split('\n');
    for (int i = 0; i < list.length; i++) {
      String zone = 'dart:async/zone.dart';
      String binding = 'package:flutter/src/rendering/binding.dart';
      String framework = 'package:flutter/src/widgets/framework.dart';
      if (list[i].contains(zone) || list[i].contains(binding) || list[i].contains(framework) || i > 100) {
        break;
      }
      handleMsg('${list[i]}');
    }
    Log.e('╚════════════════════════════════════════════════════════════════════════════╝');
  }
}