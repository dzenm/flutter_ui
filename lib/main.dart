import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_ui/base/log/handle_error.dart';
import 'package:flutter_ui/base/res/local_model.dart';
import 'package:flutter_ui/base/res/colors.dart';
import 'package:flutter_ui/base/res/strings.dart';
import 'package:flutter_ui/utils/sp_util.dart';
import 'package:provider/provider.dart';

import 'base/log/log.dart';
import 'base/widgets/keyboard/keyboard_root.dart';
import 'base/widgets/keyboard/mocks/mock_binding.dart';
import 'base/widgets/keyboard/number_keyboard.dart';
import 'base/widgets/will_pop_view.dart';
import 'pages/login/login_page.dart';
import 'pages/main/home_page/home_model.dart';
import 'pages/main/main_model.dart';
import 'pages/main/main_page.dart';
import 'pages/main/me_page/me_model.dart';
import 'pages/main/nav_page/nav_model.dart';

void main() => Application.getInstance.init();

class Application {
  /// 私有构造方法
  Application._internal();

  static final Application getInstance = Application._internal();

  factory Application() => getInstance;

  static FlutterLocalNotificationsPlugin notifications = FlutterLocalNotificationsPlugin();

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext get context => navigatorKey.currentContext!;

  /// 初始化
  void init() async {
    Log.d('═══════════════════════════════ 开始初始化 ════════════════════════════════════');
    Log.d('启动: ${DateTime.now().millisecondsSinceEpoch}');
    Log.d('Application是否单例: ${Application.getInstance == Application()}');

    Log.d('初始化 WidgetsFlutterBinding ...');
    MockBinding.ensureInitialized();

    Log.d('初始化 SharedPreferences ...');
    await SpUtil.getInstance.init();

    Log.d('初始化 阿里云推送 ...');
    _initAliYunPush();

    Log.d('初始化 系统通知 ...');
    _initSystemNotification();

    Log.d('初始化 Android设置 ...');
    _initAndroidSettings();

    Log.d('初始化 iOS设置 ...');
    _initIOSSettings();

    NumberKeyboard.register();
    Log.d('结束: ${DateTime.now().millisecondsSinceEpoch}');
    Log.d('═══════════════════════════════ 结束初始化 ════════════════════════════════════');

    // 运行flutter时全局异常捕获
    await HandleError().catchFlutterError(
      () => _runMyApp(WillPopView(behavior: BackBehavior.background, child: _getFirstPage())),
    );
  }

  /// 运行第一个页面，设置最顶层的共享数据
  Future _runMyApp(Widget child) async {
    Widget widget = MultiProvider(
      // 共享状态管理
      providers: [
        ChangeNotifierProvider(create: (context) => LocalModel()),
        ChangeNotifierProvider(create: (context) => MainModel()),
        ChangeNotifierProvider(create: (context) => HomeModel()),
        ChangeNotifierProvider(create: (context) => NavModel()),
        ChangeNotifierProvider(create: (context) => MeModel()),
      ],
      //全局主题、语言设置
      child: Consumer<LocalModel>(builder: (context, res, widget) {
        AppTheme theme = themeModel[res.theme]!;
        // Page必须放在MaterialApp中运行
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          // 设置主题，读取LocalModel的值，改变LocalModel的theme值会通过provider刷新页面
          theme: ThemeData(
            primaryColor: theme.primary,
            scaffoldBackgroundColor: theme.background,
            appBarTheme: AppBarTheme(
              brightness: Brightness.dark,
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
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver()],
          home: child,
        );
      }),
    );
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    runMockApp(KeyboardRootWidget(child: widget));
  }

  /// 初始化阿里云推送
  void _initAliYunPush() {}

  /// 初始化系统通知
  void _initSystemNotification() {
    notifications.initialize(InitializationSettings(
      android: AndroidInitializationSettings('app_icon'),
      iOS: IOSInitializationSettings(),
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
        statusBarIconBrightness: Brightness.light, // light:黑色图标 dark：白色图标, 在此处设置statusBarIconBrightness为全局设置
      ));
    }
  }

  /// 初始化iOS设置
  void _initIOSSettings() {
    if (Platform.isIOS) {}
  }

  /// 获取第一个页面
  Widget _getFirstPage() {
    Log.d('启动页面: ${DateTime.now().millisecondsSinceEpoch}');
    return SpUtil.getIsLogin() ? MainPage() : LoginPage();
  }
}
