import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'app_page.dart';
import 'base/base.dart';
import 'config/configs.dart';
import 'entities/entity.dart';
import 'http/cookie_interceptor.dart';
import 'pages/study/window/sub_window_page.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// App入口，主要做一些工具相关的初始化功能，或者是全局的状态保存，初始化完成之后进入[AppPage]
class Application {
  /// 私有构造方法
  Application._internal();

  static final Application instance = Application._internal();

  factory Application() => instance;

  BuildContext? _context;

  /// 全局context
  BuildContext get context => _context!;

  /// App入口
  void main(List<String> args) async {
    bool isMainWindow = args.firstOrNull != 'multi_window';
    if (isMainWindow) {
      MockBinding.ensureInitialized();
      // 初始化
      await _initMainApp();
      // 初始化登录过后的信息
      _initLoginState();

      // 运行flutter时全局异常捕获
      HandleError().catchFlutterError(() {
        log('╔══════════════════════════════════════════════════════════════════════════════════════════════════╗');
        log('║                                                                                                  ║');
        log('║                                        Start Flutter APP                                         ║');
        log('║                                                                                                  ║');
        log('╚══════════════════════════════════════════════════════════════════════════════════════════════════╝');
        // 让 Flutter 使用 path 策略
        usePathUrlStrategy();
        Provider.debugCheckInvalidValueType = null;
        //启动第一个页面(必须使用AppPage作为最顶层页面，包含一些页面初始化相关的信息)
        runMockApp(AppPage(handle: (ctx) => _context = ctx));
        // 初始化桌面端窗口
        DesktopWrapper.ensureInitialized();
      }, config: MessageConfig(
        handleMsg: (message) async {
          String logFileName = 'crash_${DateTime.now()}.log';
          log('异常信息文件：logFileName=$logFileName');
          await FileUtil().save(logFileName, message, dir: 'crash');
        },
      ));
    } else {
      log('APP初始运行时参数：args=${args.toString()}');
      final windowId = int.parse(args[1]);
      final argument = args[2].isEmpty ? const {} : jsonDecode(args[2]) as Map<String, dynamic>;
      runMockApp(
        SubWindowPage(
          windowController: WindowController.fromWindowId(windowId),
          args: argument,
        ),
      );
    }
  }

  /// 初始化信息
  Future<void> _initMainApp() async {
    await BuildConfig.init();
    log('╔══════════════════════════════════════════ 开始初始化 ═════════════════════════════════════════════╗');

    int now = DateTime.now().millisecondsSinceEpoch;
    int duration = 0;
    log('  启动: now=$now, duration=$duration');
    log('  Application是否单例: ${Application.instance == Application()}');

    log('  初始化 SharedPreferences');
    bool res = await SPManager().init(logPrint: Log.d);
    log('  初始化 SharedPreferences ${res ? '成功' : '失败'}');

    log('  初始化 Android设置');
    _initAndroidSettings();

    log('  初始化 iOS设置');
    _initIOSSettings();

    log('  初始化 HttpsClient');
    HttpsClient().init(
      logPrint: Log.h,
      loading: CommonDialog.loading,
      toast: CommonDialog.showToast,
      interceptors: [HttpInterceptor(), CookieInterceptor()],
      baseUrls: [Configs.baseUrl, Configs.apiUrl, Configs.localhostUrl],
    );

    log('  初始化 DBManager');
    DBManager().init(logPrint: Log.b, tables: [
      OrderEntity(),
      ProductEntity(),
      UserEntity(),
      BannerEntity(),
      ArticleEntity(),
      WebsiteEntity(),
    ]);

    log('  初始化 FileUtil');
    await FileUtil().init(logPrint: Log.i);

    log('  初始化 PluginManager');
    PluginManager.init(logPrint: Log.d);

    log('  初始化 HotkeyUtil');
    await HotkeyUtil().init(logPrint: Log.d);

    int end = DateTime.now().millisecondsSinceEpoch;
    duration = end - now;
    log('  结束: now=$end, duration=$duration');
    log('╚══════════════════════════════════════════ 结束初始化 ═════════════════════════════════════════════╝');
  }

  /// 设置登录过后的初始化信息
  void _initLoginState() {
    if (!SPManager.getUserLoginState()) return;

    String userId = SPManager.getUserId();
    // 设置用户数据库名称
    DBManager().userId = userId;
    FileUtil().initLoginUserDirectory(SPManager.getUserId());
  }

  /// 初始化Android设置
  void _initAndroidSettings() {
    if (!BuildConfig.isAndroid) return;
    // 设置Android头部的导航栏透明
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
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

  /// 打印日志
  void log(String msg) => Log.i(msg, tag: 'Application');
}
