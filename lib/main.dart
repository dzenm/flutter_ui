import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/base/res/colors.dart';
import 'package:flutter_ui/base/res/local_model.dart';
import 'package:flutter_ui/naughty/page/home/home_page.dart';
import 'package:flutter_ui/pages/login/login_page.dart';
import 'package:flutter_ui/utils/sp_util.dart';
import 'package:provider/provider.dart';

import 'base/http/log.dart';
import 'base/widgets/will_pop_scope_route.dart';
import 'models/home_model.dart';
import 'models/me_model.dart';
import 'router/route_manager.dart';
import 'router/slide_route_transition.dart';

void main() => Application.instance.init(LoginPage());

class Application {
  // 私有构造方法
  Application._internal();

  static final Application instance = Application._internal();

  factory Application() => instance;

  // 全局context
  GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

  // 初始化
  void init(Widget child) async {
    WidgetsFlutterBinding.ensureInitialized();

    RouteManager.registerConfigureRoutes();
    SpUtil.instance.init();

    Log.d('Application是否单例: ${Application.instance == Application()}');

    _runAppWidget(child);
    Log.d('run flutter app');

    // 设置Android头部的导航栏透明
    if (Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // 全局设置透明
        statusBarBrightness: Brightness.light, // light:黑色图标 dark：白色图标, 在此处设置statusBarIconBrightness为全局设置
        statusBarIconBrightness: Brightness.light, // light:黑色图标 dark：白色图标, 在此处设置statusBarIconBrightness为全局设置
      ));
    }
  }

  void _runAppWidget(Widget child) {
    runApp(MultiProvider(
      // 共享状态管理
      providers: [
        ChangeNotifierProvider(create: (context) => LocalModel()),
        ChangeNotifierProvider(create: (context) => HomeModel()),
        ChangeNotifierProvider(create: (context) => MeModel()),
      ],
      // Page必须放在MaterialApp中运行
      child: Consumer<LocalModel>(builder: (context, res, _) {
        Map theme = themeColorModel[res.themeColor]!;
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: theme['primaryColor'],
            scaffoldBackgroundColor: theme['backgroundColor'],
            appBarTheme: AppBarTheme(
              brightness: Brightness.dark,
            ),
            floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: theme['primaryColor']),
            pageTransitionsTheme: PageTransitionsTheme(builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: SlidePageTransition(),
              TargetPlatform.iOS: SlidePageTransition(),
            }),
          ),
          // 初始化toast
          routes: {
            HOME_ROUTE: (buildContext) => HomePage(),
          },
          builder: BotToastInit(),
          navigatorObservers: [BotToastNavigatorObserver()],
          title: "Flutter Demo",
          home: WillPopScopeRoute(child),
        );
      }),
    ));
  }
}
