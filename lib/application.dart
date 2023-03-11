import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/app_page.dart';

import 'base/log/handle_error.dart';
import 'base/log/log.dart';
import 'base/utils/notification_util.dart';
import 'base/utils/sp_util.dart';
import 'base/widgets/keyboard/mocks/mock_binding.dart';
import 'base/widgets/keyboard/number_keyboard.dart';
import 'math_util.dart';

/// 全局的页面
class Application {
  static const String _tag = 'Application';

  /// 私有构造方法
  Application._internal();

  static final Application instance = Application._internal();

  factory Application() => instance;

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  BuildContext get context => navigatorKey.currentContext!;

  /// 初始化
  void init() async {
    log('═══════════════════════════════ 开始初始化 ════════════════════════════════════');
    log('启动: ${DateTime.now().millisecondsSinceEpoch}');
    log('Application是否单例: ${Application.instance == Application()}');

    log('初始化 WidgetsFlutterBinding ...');
    MockBinding.ensureInitialized();

    log('初始化 SharedPreferences ...');
    bool res = await SpUtil.instance.init();
    log('初始化 SharedPreferences ${res ? '成功' : '失败'}');

    log('初始化 阿里云推送 ...');
    _initAliYunPush();

    log('初始化 系统通知 ...');
    _initSystemNotification();

    log('初始化 Android设置 ...');
    _initAndroidSettings();

    log('初始化 iOS设置 ...');
    _initIOSSettings();

    log('初始化 算法测试Main方法 ...');
    MathUtil.main();

    NumberKeyboard.register();
    log('结束: ${DateTime.now().millisecondsSinceEpoch}');
    log('═══════════════════════════════ 结束初始化 ════════════════════════════════════');

    // 运行flutter时全局异常捕获
    await HandleError().catchFlutterError(() {
      log('╔════════════════════════════════════════════════════════════════════════════╗');
      log('║                                                                            ║');
      log('║                Start Flutter APP                                           ║');
      log('║                                                                            ║');
      log('╚════════════════════════════════════════════════════════════════════════════╝');
      runMockApp(AppPage());
    });
  }

  /// 初始化阿里云推送
  void _initAliYunPush() {}

  /// 初始化系统通知
  void _initSystemNotification() {
    NotificationUtil.init();
  }

  /// 初始化Android设置
  void _initAndroidSettings() {
    if (!Platform.isAndroid) return;
    // 设置Android头部的导航栏透明
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      // 全局设置透明
      statusBarBrightness: Brightness.light,
      // light:黑色图标 dark：白色图标, 在此处设置statusBarIconBrightness为全局设置
      statusBarIconBrightness: Brightness.light,
    ));
  }

  /// 初始化iOS设置
  void _initIOSSettings() {
    if (!Platform.isIOS) return;
  }

  /// 打印日志
  void log(String msg) {
    Log.i(msg, tag: _tag);
  }
}
