import 'dart:collection';
import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player_media_kit/video_player_media_kit.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

import 'app_page.dart';
import 'base/base.dart';
import 'config/configs.dart';
import 'entities/entity.dart';
import 'http/cookie_interceptor.dart';
import 'pages/study/window/sub_window_page.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// App入口，主要做一些工具相关的初始化功能，或者是全局的状态保存，初始化完成之后进入[AppPage]
class Application with Logging {
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
      // 初始化
      await _initApp(args);
      // 初始化登录过后的信息
      _initLoginState();

      // 运行flutter时全局异常捕获
      HandleError().catchFlutterError(
        () {
          logInfo('╔══════════════════════════════════════════════════════════════════════════════════════════════════╗');
          logInfo('║                                                                                                  ║');
          logInfo('║                                        Start Flutter APP                                         ║');
          logInfo('║                                                                                                  ║');
          logInfo('╚══════════════════════════════════════════════════════════════════════════════════════════════════╝');
          //启动第一个页面(必须使用AppPage作为最顶层页面，包含一些页面初始化相关的信息)
          runMockApp(AppPage(handle: (ctx) => _context = ctx));
        },
        config: MessageConfig(
          handleMsg: (message) async {
            String logFileName = 'crash_${DateTime.now()}.log';
            logInfo('异常信息文件：logFileName=$logFileName');
            await FileUtil().save(logFileName, message, dir: 'crash');
          },
        ),
      );
    } else {
      logInfo('APP初始运行时参数：args=${args.toString()}');
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
  Future<void> _initApp(List<String> args) async {
    MockBinding.ensureInitialized();
    await BuildConfig.init();
    Log.init(
      manager: LogManager(
        config: LogConfig(packageName: BuildConfig.packageInfo.packageName),
      ),
    );
    logInfo('╔══════════════════════════════════════════ 开始初始化 ═════════════════════════════════════════════╗');

    int now = DateTime.now().millisecondsSinceEpoch;
    int duration = 0;
    logInfo('  启动: now=$now, duration=$duration');
    logInfo('  Application是否单例: ${Application.instance == Application()}');

    _initAndroid();
    _initIOS();
    _initWindows(args);
    _initMacOS();
    _initLinux();
    _initWeb();
    // 初始化桌面端窗口
    await DesktopWrapper.ensureInitialized();

    logInfo('  初始化 SharedPreferences');
    bool res = await SPManager().init(logPrint: Log.d);
    logInfo('  初始化 SharedPreferences ${res ? '成功' : '失败'}');

    logInfo('  初始化 HttpsClient');
    HttpsClient().init(
      logPrint: BuildConfig.showHTTPLog ? Log.h : null,
      loading: CommonDialog.loading,
      toast: CommonDialog.showToast,
      interceptors: [HttpInterceptor(), CookieInterceptor()],
      baseUrls: [Configs.baseUrl, Configs.apiUrl, Configs.localhostUrl],
    );

    logInfo('  初始化 DBManager');
    DBManager().init(logPrint: BuildConfig.showDBLog ? Log.b : null, tables: [
      OrderEntity(),
      ProductEntity(),
      UserEntity(),
      BannerEntity(),
      ArticleEntity(),
      WebsiteEntity(),
    ]);

    logInfo('  初始化 FileUtil');
    await FileUtil().init(logPrint: Log.i);

    logInfo('  初始化 PluginManager');
    PluginManager.init(logPrint: Log.d);

    logInfo('  初始化 HotkeyUtil');
    await HotkeyUtil().init(logPrint: Log.d);

    logInfo('  初始化 VideoPlayerMediaKit');
    VideoPlayerMediaKit.ensureInitialized(
      macOS: true,
      windows: true,
      linux: true,
    );

    int end = DateTime.now().millisecondsSinceEpoch;
    duration = end - now;
    logInfo('  结束: now=$end, duration=$duration');
    logInfo('╚══════════════════════════════════════════ 结束初始化 ═════════════════════════════════════════════╝');
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
  Future<void> _initAndroid() async {
    if (!BuildConfig.isAndroid) return;
    logInfo('  初始化 Android设置');
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
  Future<void> _initIOS() async {
    if (!BuildConfig.isIOS) return;
    logInfo('  初始化 iOS设置');
  }

  /// 初始化Windows设置
  Future<void> _initWindows(List<String> args) async {
    if (!BuildConfig.isWindows) return;
    logInfo('  初始化 Windows设置');
    await WindowsSingleInstance.ensureSingleInstance(
      args,
      "windows_custom_identifier",
      onSecondWindow: (args) {
        logInfo('WindowsSingleInstance：args=$args');
      },
    );
  }

  /// 初始化MacOS设置
  Future<void> _initMacOS() async {
    if (!BuildConfig.isMacOS) return;
    logInfo('  初始化 MacOS设置');
  }

  /// 初始化Linux设置
  Future<void> _initLinux() async {
    if (!BuildConfig.isLinux) return;
    logInfo('  初始化 Linux设置');
  }

  /// 初始化Web设置
  Future<void> _initWeb() async {
    if (!BuildConfig.isWeb) return;
    logInfo('  初始化 Web设置');
  }
}
