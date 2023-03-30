import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'log.dart';

/// 处理字符串
typedef HandleMsg = void Function(String message);

///
/// Created by a0010 on 2022/3/22 09:38
/// 全局处理错误信息
///
/// 在pubspec.yaml添加下列依赖
/// # 获取硬件设备信息
///  device_info: ^0.4.0+1
///  # 获取APP相关信息
///  package_info: ^0.4.0+2
///
///    HandleError().catchFlutterError(() {
///      runMockApp(AppPage(child: _initApp()));
///    }, handleMsg: (message) async {
///      String logFileName = 'crash_${DateTime.now()}.log';
///      await FileUtil.instance.save(logFileName, message, dir: 'crash').then((String? filePath) async {});
///    });
class HandleError {
  // 捕获flutter运行时的错误
  Future catchFlutterError(
    Function runApp, {
    HandleMsg? handleMsg,
    bool showPackageInfo = true,
    bool showDeviceInfo = false,
    bool showStackInfo = true,
    bool showLogInConsole = true,
  }) async {
    // 进行异常捕获并输出
    FlutterError.onError = (FlutterErrorDetails details) async {
      if (handleMsg == null) {
        // 3.3之后使用
        // FlutterError.presentError(details);
        FlutterError.dumpErrorToConsole(details);
      } else {
        Zone.current.handleUncaughtError(details.exception, details.stack!);
      }
    };
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

    // flutter sdk 3.3之后使用下面的方式捕获异常
    PlatformDispatcher.instance.onError = (dynamic error, StackTrace stackTrace) {
      // 处理异常信息
      _handleMessage(error, stackTrace, handleMsg, showPackageInfo, showDeviceInfo, showStackInfo, showLogInConsole);
      return true;
    };
    runApp();
    return;
    // flutter sdk 3.3之前使用下面的方式捕获异常
    runZonedGuarded(() {
      // 在这里启动Flutter APP之后，所有的异常信息才能捕获成功
      runApp();
    }, (dynamic error, StackTrace stackTrace) async {
      // 处理异常信息
      _handleMessage(error, stackTrace, handleMsg, showPackageInfo, showDeviceInfo, showStackInfo, showLogInConsole);
    });
  }

  /// 处理信息
  Future _handleMessage(
    dynamic error,
    StackTrace stackTrace,
    HandleMsg? handleMsg,
    bool showPackageInfo,
    bool showDeviceInfo,
    bool showStackInfo,
    bool showLogInConsole,
  ) async {
    StringBuffer sb = StringBuffer();
    const String interval = '  '; // 缩进的距离
    // 打印日志
    void log(dynamic msg) => showLogInConsole ? Log.e(msg, tag: 'HandleError') : null;
    // 处理单条信息
    void handleSingleMessage(String message, {bool needLog = true}) {
      if (message.isEmpty || message == '\n') return; // 过滤空白信息和换行符
      if (needLog) log('║$interval$message'); // 打印在控制台
      sb.write('$message\n'); // 转化为文本
    }

    log('╔════════════════════════════════════════════════════════════════════════════╗');
    log('║                                                                            ║');
    log('║                Handle Flutter Error                                        ║');
    log('║                                                                            ║');
    log('╚════════════════════════════════════════════════════════════════════════════╝');

    if (showPackageInfo || showDeviceInfo) {
      log('╔══════════════════════════════ Phone Info ══════════════════════════════════╗');
    }
    // 包名信息
    Map<String, dynamic> packageInfo = await getPackageInfo();
    for (var key in packageInfo.keys) handleSingleMessage('$key: ${packageInfo[key]}', needLog: showPackageInfo);
    // 设备信息
    Map<String, dynamic> devicesInfo = await getPackageInfo();
    for (var key in devicesInfo.keys) handleSingleMessage('$key: ${devicesInfo[key]}', needLog: showDeviceInfo);

    // 异常信息
    log('║══════════════════════════════ Error Info ═══════════════════════════════════');
    handleSingleMessage('$interval$error\n');

    // 异常信息栈
    if (showStackInfo) {
      log('║══════════════════════════════ Stack Trace ══════════════════════════════════');
    }
    List<String> stackInfo = stackTrace.toString().split('\n');
    for (var msg in stackInfo) handleSingleMessage(msg, needLog: showStackInfo);

    log('╚════════════════════════════════════════════════════════════════════════════');

    if (handleMsg == null) return;
    // 处理信息，可以保存文本信息为文件或者上传至服务器
    handleMsg(sb.toString());
  }

  /// 获取APP信息
  Future<Map<String, dynamic>> getPackageInfo() async {
    PackageInfo info = await PackageInfo.fromPlatform();
    return {
      'APP Info': '',
      'appName': info.appName,
      'packageName': info.packageName,
      'version': info.version,
      'buildNumber': info.buildNumber,
      'buildSignature': info.buildSignature,
    };
  }

  /// 设备信息
  Future<Map<String, dynamic>> getDeviceInfo() async {
    DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();
    dynamic info = {};
    if (Platform.isAndroid) {
      info = (await infoPlugin.androidInfo).data;
    } else if (Platform.isIOS) {
      info = (await infoPlugin.iosInfo).data;
    }
    return {'Device Info': ''}..addAll(info);
  }
}
