import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'build_config.dart';
import 'log.dart';

/// 处理字符串
typedef HandleMsg = void Function(String message);

///
/// Created by a0010 on 2022/3/22 09:38
/// 全局处理错误信息
/// HandleError().catchFlutterError(() {
///   runMockApp(AppPage(child: _initApp()));
/// }, config: MessageConfig(handleMsg: (message) async {
///     String logFileName = 'crash_${DateTime.now()}.log';
///     await FileUtil()save(logFileName, message, dir: 'crash').then((String? filePath) async {});
///   }),
/// )
class HandleError {
  /// 捕获flutter运行时的错误
  Future catchFlutterError(
    Function runApp, {
    MessageConfig? config,
  }) async {
    MessageConfig messageConfig = config ?? MessageConfig();
    // 进行异常捕获并输出
    FlutterError.onError = (FlutterErrorDetails details) async {
      if (messageConfig.handleMsg == null) {
        // 3.3之后使用
        // FlutterError.presentError(details);
        FlutterError.dumpErrorToConsole(details);
      } else {
        if (details.stack != null) {
          Zone.current.handleUncaughtError(details.exception, details.stack!);
        }
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
      _handleMessage(error, stackTrace, messageConfig);
      return true;
    };
    // 进入App前先初始化信息
    runApp();
    return;
    // flutter sdk 3.3之前使用下面的方式捕获异常
    // runZonedGuarded(() {
    //   // 在这里启动Flutter APP之后，所有的异常信息才能捕获成功
    //   runApp();
    // }, (dynamic error, StackTrace stackTrace) async {
    //   // 处理异常信息
    //   _handleMessage(error, stackTrace, handleMsg, showPackageInfo, showDeviceInfo, showStackInfo, showLogInConsole);
    // });
  }

  /// 处理信息
  /// [error] 错误文本信息
  /// [stackTrace] 错误的堆栈信息
  /// [config] 信息输出配置
  void _handleMessage(
    dynamic error,
    StackTrace stackTrace,
    MessageConfig config,
  ) {
    StringBuffer sb = StringBuffer();
    const String interval = '  '; // 缩进的距离
    // 打印日志
    void log(dynamic msg) => config.showLogInConsole ? Log.e(msg, tag: 'HandleError') : null;
    // 处理单条信息
    void handleSingleMessage(String message, {bool needLog = true}) {
      if (message.isEmpty || message == '\n') return; // 过滤空白信息和换行符
      if (needLog) log('║$interval$message'); // 打印在控制台
      sb.write('$message\n'); // 转化为文本
    }

    log('╔══════════════════════════════════════════════════════════════════════════════════════════════════╗');
    log('║                                                                                                  ║');
    log('║                                       Handle Flutter Error                                       ║');
    log('║                                                                                                  ║');
    log('╚══════════════════════════════════════════════════════════════════════════════════════════════════╝');

    // 包名信息
    if (config.showPackageInfo) {
      log('╔═════════════════════════════════════════ Package Info ════════════════════════════════════════════');
    }
    Map<String, dynamic> packageInfo = BuildConfig.getPackageInfo();
    for (var key in packageInfo.keys) {
      handleSingleMessage('$key: ${packageInfo[key]}', needLog: config.showPackageInfo);
    }

    // 设备信息
    if (config.showDeviceInfo) {
      log('║═════════════════════════════════════════ Device Info ═════════════════════════════════════════════');
    }
    Map<String, dynamic> devicesInfo = BuildConfig.getDeviceInfo();
    for (var key in devicesInfo.keys) {
      handleSingleMessage('$key: ${devicesInfo[key]}', needLog: config.showDeviceInfo);
    }

    // 异常信息
    log('║═════════════════════════════════════════ Error Info ══════════════════════════════════════════════');
    handleSingleMessage('$error');

    // 异常信息栈
    List<String> stackInfo = stackTrace.toString().split('\n');
    if (config.showStackInfo && stackInfo.isNotEmpty) {
      log('║═════════════════════════════════════════ Stack Trace ═════════════════════════════════════════════');
    }
    for (var msg in stackInfo) {
      handleSingleMessage(msg, needLog: config.showStackInfo);
    }

    log('╚═══════════════════════════════════════════════════════════════════════════════════════════════════');

    if (config.handleMsg == null) return;
    // 处理信息，可以保存文本信息为文件或者上传至服务器
    config.handleMsg!(sb.toString());
  }

}

class MessageConfig {
  HandleMsg? handleMsg; // 自定义处理错误信息
  bool showPackageInfo; // 是否显示包相关信息
  bool showDeviceInfo; // 是否显示设备相关信息
  bool showStackInfo; // 是否显示堆栈信息
  bool showLogInConsole; // 是否在控制台打印错误信息
  MessageConfig({
    this.handleMsg,
    this.showPackageInfo = true,
    this.showDeviceInfo = false,
    this.showStackInfo = true,
    this.showLogInConsole = true,
  });
}
