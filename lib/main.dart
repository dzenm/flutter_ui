import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/naughty/page/home/home_page.dart';
import 'package:flutter_ui/pages/login/login_page.dart';
import 'package:flutter_ui/utils/sp_util.dart';
import 'package:flutter_ui/view_models/home_view_model.dart';
import 'package:flutter_ui/view_models/me_view_model.dart';
import 'package:provider/provider.dart';

import 'http/log.dart';
import 'router/route_manager.dart';
import 'router/slide_route_transition.dart';
import 'widgets/will_pop_scope_route.dart';

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
  }

  void _runAppWidget(Widget child) {
    runApp(MultiProvider(
      // 共享状态管理
      providers: [
        ChangeNotifierProvider(create: (context) => HomeViewModel()),
        ChangeNotifierProvider(create: (context) => MeViewModel()),
      ],
      // Page必须放在MaterialApp中运行
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
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
      ),
    ));
  }
}
