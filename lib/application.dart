import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'app_page.dart';
import 'base/base.dart';
import 'config/configs.dart';
import 'entities/article_entity.dart';
import 'entities/banner_entity.dart';
import 'entities/user_entity.dart';
import 'entities/website_entity.dart';
import 'http/cookie_interceptor.dart';

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

  /// 在[MaterialApp]设置
  set context(BuildContext context) {
    _context = context;
  }

  /// App入口
  void main() async {
    await _init();
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
      runMockApp(const AppPage());
    }, handleMsg: (message) async {
      String logFileName = 'crash_${DateTime.now()}.log';
      await FileUtil.instance.save(logFileName, message, dir: 'crash');
    });
  }

  // 初始化信息
  Future<void> _init() async {
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

    log('初始化 Android设置');
    _initAndroidSettings();

    log('初始化 iOS设置');
    _initIOSSettings();

    log('初始化 DBManager');
    DBManager.instance.init(logPrint: Log.b, tables: [
      UserEntity(),
      BannerEntity(),
      ArticleEntity(),
      WebsiteEntity(),
    ]);

    log('初始化 HttpsClient');
    HttpsClient.instance.init(
      logPrint: Log.h,
      loading: CommonDialog.loading,
      toast: CommonDialog.showToast,
      interceptors: [HttpInterceptor(), CookieInterceptor()],
      baseUrls: [Configs.baseUrl, Configs.apiUrl, Configs.localhostUrl],
    );

    log('初始化 RouteManager');
    RouteManager.init(logPrint: Log.i);

    log('初始化 FileUtil');
    FileUtil.instance.init(logPrint: Log.i);

    log('初始化 PluginManager');
    PluginManager.init(logPrint: Log.d);

    await DesktopHelper.init();

    int end = DateTime.now().millisecondsSinceEpoch;
    duration = end - now;
    log('结束: now=$end, duration=$duration');
    log('═══════════════════════════════════════════ 结束初始化 ══════════════════════════════════════════════');
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
