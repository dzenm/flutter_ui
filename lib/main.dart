import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

import 'base/log/handle_error.dart';
import 'base/log/log.dart';
import 'base/model/local_model.dart';
import 'base/res/strings.dart';
import 'base/res/theme/app_theme.dart';
import 'base/utils/sp_util.dart';
import 'base/widgets/keyboard/keyboard_root.dart';
import 'base/widgets/keyboard/mocks/mock_binding.dart';
import 'base/widgets/keyboard/number_keyboard.dart';
import 'base/widgets/will_pop_view.dart';
import 'math_util.dart';
import 'models/article_model.dart';
import 'models/banner_model.dart';
import 'pages/login/login_page.dart';
import 'pages/main/home_page/home_model.dart';
import 'pages/main/main_model.dart';
import 'pages/main/main_page.dart';
import 'pages/main/me_page/me_model.dart';
import 'pages/main/nav_page/nav_model.dart';
import 'pages/study/study_model.dart';

void main() => Application.instance.init();

class Application {
  /// 私有构造方法
  Application._internal();

  static final Application instance = Application._internal();

  factory Application() => instance;

  static FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext get context => navigatorKey.currentContext!;

  static const String _tag = 'Application';

  /// 初始化
  void init() async {
    Log.i('═══════════════════════════════ 开始初始化 ════════════════════════════════════', tag: _tag);
    Log.i('启动: ${DateTime.now().millisecondsSinceEpoch}', tag: _tag);
    Log.i('Application是否单例: ${Application.instance == Application()}', tag: _tag);

    Log.i('初始化 WidgetsFlutterBinding ...', tag: _tag);
    MockBinding.ensureInitialized();

    Log.i('初始化 SharedPreferences ...', tag: _tag);
    await SpUtil.instance.init();

    Log.i('初始化 阿里云推送 ...', tag: _tag);
    _initAliYunPush();

    Log.i('初始化 系统通知 ...', tag: _tag);
    _initSystemNotification();

    Log.i('初始化 Android设置 ...', tag: _tag);
    _initAndroidSettings();

    Log.i('初始化 iOS设置 ...', tag: _tag);
    _initIOSSettings();

    MathUtil.main();

    NumberKeyboard.register();
    Log.i('结束: ${DateTime.now().millisecondsSinceEpoch}', tag: _tag);
    Log.i('═══════════════════════════════ 结束初始化 ════════════════════════════════════', tag: _tag);

    // 运行flutter时全局异常捕获
    await HandleError().catchFlutterError(() {
      Log.i('╔════════════════════════════════════════════════════════════════════════════╗', tag: _tag);
      Log.i('║                                                                            ║', tag: _tag);
      Log.i('║                Start Flutter APP                                           ║', tag: _tag);
      Log.i('║                                                                            ║', tag: _tag);
      Log.i('╚════════════════════════════════════════════════════════════════════════════╝', tag: _tag);
      _runMyApp(WillPopView(behavior: BackBehavior.background, child: _startPage()));
    });
  }

  /// 运行第一个页面，设置最顶层的共享数据
  Future _runMyApp(Widget child) async {
    //全局主题、语言设置
    Widget consumerApp = Consumer<LocalModel>(builder: (context, res, widget) {
      // Page必须放在MaterialApp中运行
      AppTheme? theme = res.appTheme;
      return MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        // 设置主题，读取LocalModel的值，改变LocalModel的theme值会通过provider刷新页面
        theme: ThemeData(
          primaryColor: theme.primary,
          appBarTheme: AppBarTheme(
            backgroundColor: theme.primary,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: theme.primary,
          ),
          // pageTransitionsTheme: PageTransitionsTheme(
          //   builders: <TargetPlatform, PageTransitionsBuilder>{
          //     TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          //     TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          //   },
          // ),
        ),
        // 初始路由
        initialRoute: '/',
        // 设置语言，读取LocalModel的值，改变LocalModel的locale值会通过provider刷新页面
        locale: res.locale,
        // 国际化的Widget
        localizationsDelegates: S.localizationsDelegates,
        // 国际化语言包
        supportedLocales: S.supportedLocales,
        builder: (context, child) {
          final botToastBuilder = BotToastInit();
          Widget toastWidget = botToastBuilder(context, child);
          Widget fontWidget = MediaQuery(
            //设置文字大小不随系统设置改变
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: toastWidget,
          );
          return fontWidget;
        },
        navigatorObservers: [BotToastNavigatorObserver()],
        home: child,
      );
    });
    // 全局适配屏幕
    // Widget screenUtilApp = ScreenUtilInit(
    //   designSize: const Size(414, 896),
    //   minTextAdapt: true,
    //   splitScreenMode: true,
    //   builder: () => consumerApp,
    // );
    // 共享状态管理
    Widget providerApp = MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocalModel()),
        ChangeNotifierProvider(create: (context) => MainModel()),
        ChangeNotifierProvider(create: (context) => HomeModel()),
        ChangeNotifierProvider(create: (context) => NavModel()),
        ChangeNotifierProvider(create: (context) => MeModel()),
        ChangeNotifierProvider(create: (context) => ArticleModel()),
        ChangeNotifierProvider(create: (context) => BannerModel()),
        ChangeNotifierProvider(create: (context) => StudyModel()),
      ],
      child: consumerApp,
    );
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    runMockApp(KeyboardRootWidget(child: providerApp));
  }

  /// 初始化阿里云推送
  void _initAliYunPush() {}

  /// 初始化系统通知
  void _initSystemNotification() {
    notifications.initialize(InitializationSettings(
      android: AndroidInitializationSettings('icon_launcher'),
      iOS: DarwinInitializationSettings(),
    ));
  }

  /// 初始化Android设置
  void _initAndroidSettings() {
    // 设置Android头部的导航栏透明
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        // 全局设置透明
        statusBarBrightness: Brightness.light,
        // light:黑色图标 dark：白色图标, 在此处设置statusBarIconBrightness为全局设置
        statusBarIconBrightness: Brightness.light,
      ));
    }
  }

  /// 初始化iOS设置
  void _initIOSSettings() {
    if (Platform.isIOS) {}
  }

  /// 获取第一个页面
  Widget _startPage() {
    Log.i('启动页面: ${DateTime.now().millisecondsSinceEpoch}', tag: _tag);
    return SpUtil.getUserLoginState() ? MainPage() : LoginPage();
  }
}
