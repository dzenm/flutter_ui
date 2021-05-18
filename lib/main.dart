import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/pages/login/login_page.dart';
import 'package:flutter_ui/router/navigator_utils.dart';
import 'package:flutter_ui/utils/sp_util.dart';
import 'package:flutter_ui/view_models/home_view_model.dart';
import 'package:flutter_ui/view_models/me_view_model.dart';
import 'package:provider/provider.dart';

import 'channels/android_back_action.dart';

void main() => init(LoginPage());

void init(Widget app) async {
  WidgetsFlutterBinding.ensureInitialized();

  BaseRouter.registerConfigureRoutes();
  SpUtil.instance.init();
  runApp(MultiProvider(
    // 共享状态管理
    providers: [
      ChangeNotifierProvider(create: (context) => HomeViewModel()),
      ChangeNotifierProvider(create: (context) => MeViewModel()),
    ],
    // Page必须放在MaterialApp中运行
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        platform: TargetPlatform.iOS,
        primarySwatch: Colors.lightBlue,
        // pageTransitionsTheme: PageTransitionsTheme(builders: <TargetPlatform, PageTransitionsBuilder>{
        //   TargetPlatform.android: SlidePageTransition(),
        //   TargetPlatform.iOS: SlidePageTransition(),
        // }),
      ),
      // 初始化toast
      builder: BotToastInit(),
      title: "Flutter Demo",
      home: WillPopScopeRoute(app),
    ),
  ));
}
