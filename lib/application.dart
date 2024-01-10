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
import 'pages/study/window_page/sub_window_page.dart';

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
  void main(List<String> args) async {
    bool isMainWindow = args.firstOrNull != 'multi_window';
    if (isMainWindow) {
      MockBinding.ensureInitialized();
      await _initMainApp();
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
        // 初始化桌面端窗口
        DesktopWrapper.ensureInitialized();
      }, handleMsg: (message) async {
        String logFileName = 'crash_${DateTime.now()}.log';
        await FileUtil().save(logFileName, message, dir: 'crash');
      });
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
    log('═══════════════════════════════════════════ 开始初始化 ══════════════════════════════════════════════');

    int now = DateTime.now().millisecondsSinceEpoch;
    int duration = 0;
    log('启动: now=$now, duration=$duration');
    log('Application是否单例: ${Application.instance == Application()}');

    log('初始化 SharedPreferences');
    bool res = await SpUtil().init(logPrint: Log.i);
    log('初始化 SharedPreferences ${res ? '成功' : '失败'}');

    log('初始化 Android设置');
    _initAndroidSettings();

    log('初始化 iOS设置');
    _initIOSSettings();

    log('初始化 HttpsClient');
    HttpsClient().init(
      logPrint: Log.h,
      loading: CommonDialog.loading,
      toast: CommonDialog.showToast,
      interceptors: [HttpInterceptor(), CookieInterceptor()],
      baseUrls: [Configs.baseUrl, Configs.apiUrl, Configs.localhostUrl],
    );

    log('初始化 DBManager');
    DBManager().init(logPrint: Log.b, tables: [
      OrderEntity(),
      ProductEntity(),
      UserEntity(),
      BannerEntity(),
      ArticleEntity(),
      WebsiteEntity(),
    ]);

    log('初始化 FileUtil');
    FileUtil().init(logPrint: Log.i);

    log('初始化 PluginManager');
    PluginManager.init(logPrint: Log.d);

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
/// 车速
///                12分      9分      6分      3分      1分
/// 大车  高快      20%               0%
///       非高快             50%      20%      20%      10%
/// 小车  高快      50%               20%      0%
///       非高快                      50%      20%      0%


/// 12分
/// 酒驾
/// 不犯罪的事故逃逸
/// 假证假牌
/// 大车超人20%小车超人100%
/// 高快倒逆调
/// 大车高快超速20%小车高快超速50%
/// 代扣分
///
/// 9分
/// 7座超人50%
/// 大车非高快50%
/// 高快路违停
/// 无牌挡牌车牌不一违规校车
/// 大车4时不休或休息时长低于20分钟
///
/// 6分
/// 大车超人7座超人20%小车超人50%
/// 大车高快超速非高快超速20%，小车高快超速20%非高快超速50%
/// 超重50%
/// 物车时速线标不明
/// 危车乱行
/// 不按信号灯驾驶
/// 扣证
/// 撞车轻伤逃逸不犯罪
/// 高快占急道
///
/// 3分
/// 非大车超人20%
/// 货车非高快超速20%
/// 高快路乱跑车道
/// 人行道不让人
/// 不按规定超车让行，非高快逆行，插队占道，打电话，不让校车
/// 大车超重30%，违规载客
/// 车牌位置不正确
/// 事故灯光警标不正确
/// 大车不定期检查
/// 校车存在安全隐患的车
/// 载货车4时不休或休息时长低于20分钟
/// 高速低于最低速
///
/// 1分
/// 大车非高快超速10%
/// 灯光会车不正确
/// 非高快倒调
/// 标线不正确
/// 超过规定宽高车
/// 超重
/// 非大车不定期检查
/// 改变车结构
/// 不寄安全带和头盔