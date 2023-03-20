import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'log.dart';

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
///  device_info: ^0.4.0+1
///  # 获取APP相关信息
///  package_info: ^0.4.0+2
///    await HandleError().catchFlutterError(() {
///      log('╔════════════════════════════════════════════════════════════════════════════╗');
///      log('║                                                                            ║');
///      log('║                Start Flutter APP                                           ║');
///      log('║                                                                            ║');
///      log('╚════════════════════════════════════════════════════════════════════════════╝');
///      runMockApp(AppPage(child: _initApp()));
///    }, handleMsg: (msg) async {
///      String logFileName = 'crash_${DateTime.now()}.log';
///      await FileUtil.instance.save(logFileName, msg, dir: 'crash').then((String? filePath) async {});
///    });
class HandleError {
  // 私有构造方法
  HandleError._internal();

  static final HandleError _instance = HandleError._internal();

  static HandleError get instance => _instance;

  factory HandleError() => _instance;

  static const String _tag = 'HandleError';

  // 捕获flutter运行时的错误
  Future catchFlutterError(RunFlutterAPP runFlutterAPP, {HandleMsg? handleMsg}) async {
    // 进行异常捕获并输出
    FlutterError.onError = (FlutterErrorDetails details) async {
      if (handleMsg == null) {
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

    runZonedGuarded(() async {
      // 在这里启动Flutter APP之后，所有的异常信息才能捕获成功
      runFlutterAPP();
    }, (dynamic error, StackTrace stackTrace) async {
      // 出现异常后，在这里处理异常
      Log.e('╔════════════════════════════════════════════════════════════════════════════╗', tag: _tag);
      Log.e('║                                                                            ║', tag: _tag);
      Log.e('║                Handle Flutter Error                                        ║', tag: _tag);
      Log.e('║                                                                            ║', tag: _tag);
      Log.e('╚════════════════════════════════════════════════════════════════════════════╝', tag: _tag);

      // 将错误转为文本信息并保存为文件
      await _convertToText(error, stackTrace).then((msg) {
        if (handleMsg != null) {
          // 处理信息，可以保存文本信息为文件或者上传至服务器
          handleMsg(msg);
        }
      });
    });
  }

  /// 收集信息并转化为文本信息
  Future<String> _convertToText(dynamic error, StackTrace stackTrace) async {
    StringBuffer sb = StringBuffer();
    void write(String msg) {
      // 打印在控制台
      Log.e('║$interval$msg');
      // 转化为文本
      sb.write('$msg\n');
    }

    Map<String, dynamic> info = await getAppInfo();
    Log.e('╔══════════════════════════════ Phone Info ══════════════════════════════════╗, tag: _tag');
    info.forEach((key, value) => write('$key: $value'));

    Log.e('║══════════════════════════════ Error Info ═══════════════════════════════════, tag: _tag');
    List<String> list = getAppError(error, stackTrace);
    for (var msg in list) {
      if (msg == '@分割线@') {
        Log.e('║══════════════════════════════ Stack Trace ══════════════════════════════════, tag: _tag');
      } else {
        write(msg);
      }
    }
    return sb.toString();
  }

  /// 获取APP信息
  Future<Map<String, dynamic>> getAppInfo() async {
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
    Map<String, dynamic> deviceInfo = {};
    DeviceInfoPlugin infoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo info = await infoPlugin.androidInfo;
      deviceInfo = info.data;
    } else if (Platform.isIOS) {
      IosDeviceInfo info = await infoPlugin.iosInfo;
      deviceInfo = info.data;
    }

    Map<String, dynamic> res = {};
    res['APP Info'] = '';
    res.addAll(appInfo);
    res['Device Info'] = '';
    res.addAll(deviceInfo);
    return res;
  }

  /// 获取APP异常信息
  List<String> getAppError(dynamic error, StackTrace stackTrace) {
    // 异常信息
    List<String> res = [];
    res.add('\n$interval$error\n');

    // 异常信息栈
    List<String> list = stackTrace.toString().split('\n');
    if (list.isNotEmpty) {
      res.add("@分割线@");
      res.addAll(list);
    }
    return res;
  }
}
