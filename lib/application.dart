import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/base/log/build_config.dart';

import 'app_page.dart';
import 'base/db/db_manager.dart';
import 'base/http/https_client.dart';
import 'base/log/handle_error.dart';
import 'base/log/log.dart';
import 'base/naughty/http_interceptor.dart';
import 'base/utils/route_manager.dart';
import 'base/utils/file_util.dart';
import 'base/utils/native_channel_util.dart';
import 'base/utils/sp_util.dart';
import 'base/widgets/common_dialog.dart';
import 'base/widgets/keyboard/mocks/mock_binding.dart';
import 'base/widgets/keyboard/number_keyboard.dart';
import 'http/cookie_interceptor.dart';
import 'math_util.dart';
import 'pages/login/login_page.dart';
import 'pages/main/main_page.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// 全局的页面
class Application {
  /// 私有构造方法
  Application._internal();

  static final Application instance = Application._internal();

  factory Application() => instance;

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  BuildContext get context => navigatorKey.currentContext!;

  /// 初始化
  void init() async {
    log('═══════════════════════════════════════════ 开始初始化 ══════════════════════════════════════════════');

    int now = DateTime.now().millisecondsSinceEpoch;
    int duration = 0;
    log('启动: now=$now, duration=$duration');
    log('Application是否单例: ${Application.instance == Application()}');

    log('初始化 WidgetsFlutterBinding');
    MockBinding.ensureInitialized();

    log('初始化 SharedPreferences');
    bool res = await SpUtil.instance.init(logPrint: Log.i);
    log('初始化 SharedPreferences ${res ? '成功' : '失败'}');

    log('初始化 阿里云推送');
    _initAliYunPush();

    log('初始化 系统通知');
    _initSystemNotification();

    log('初始化 Android设置');
    _initAndroidSettings();

    log('初始化 iOS设置');
    _initIOSSettings();

    log('初始化 DBManager');
    DBManager.instance.init(logPrint: Log.b);

    log('初始化 HttpsClient');
    HttpsClient.instance.init(
      logPrint: Log.h,
      loading: CommonDialog.loading,
      toast: CommonDialog.showToast,
      interceptors: [HttpInterceptor(), CookieInterceptor()],
    );

    log('初始化 RouteManager');
    RouteManager.init(logPrint: Log.i);

    log('初始化 FileUtil');
    FileUtil.instance.init(logPrint: Log.i);

    log('初始化 NativeChannelUtil');
    NativeChannelUtil.init(logPrint: Log.d);

    log('初始化 算法测试Main方法');
    MathUtil.main();

    NumberKeyboard.register();

    int end = DateTime.now().millisecondsSinceEpoch;
    duration = end - now;
    log('结束: now=$end, duration=$duration');
    log('═══════════════════════════════════════════ 结束初始化 ══════════════════════════════════════════════');

    // 运行flutter时全局异常捕获
    HandleError().catchFlutterError(() {
      log('╔══════════════════════════════════════════════════════════════════════════════════════════════════╗');
      log('║                                                                                                  ║');
      log('║                                        Start Flutter APP                                         ║');
      log('║                                                                                                  ║');
      log('╚══════════════════════════════════════════════════════════════════════════════════════════════════╝');
      runMockApp(AppPage(child: _initApp()));
    }, handleMsg: (message) async {
      String logFileName = 'crash_${DateTime.now()}.log';
      await FileUtil.instance.save(logFileName, message, dir: 'crash').then((String? filePath) async {});
    });
  }

  /// 初始化阿里云推送
  void _initAliYunPush() {}

  /// 初始化系统通知
  void _initSystemNotification() {}

  /// 初始化Android设置
  void _initAndroidSettings() {
    if (!BuildConfig.isAndroid) return;
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
    if (!BuildConfig.isIOS) return;
  }

  /// 获取第一个页面
  Widget _initApp() {
    if (SpUtil.getUserLoginState()) {
      return MainPage();
    }
    return LoginPage();
  }

  /// 打印日志
  void log(String msg) => Log.i(msg, tag: 'Application');
}
