import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'application.dart';
import 'base/log/build_config.dart';
import 'base/res/app_theme.dart';
import 'base/res/local_model.dart';
import 'base/route/app_route_delegate.dart';
import 'base/route/app_route_info_parser.dart';
import 'base/utils/sp_util.dart';
import 'base/widgets/common_dialog.dart';
import 'generated/l10n.dart';
import 'models/article_model.dart';
import 'models/banner_model.dart';
import 'models/user_model.dart';
import 'models/website_model.dart';
import 'pages/main/home/home_model.dart';
import 'pages/main/main_model.dart';
import 'pages/main/me/me_model.dart';
import 'pages/main/nav/nav_model.dart';
import 'pages/my/my_page.dart';
import 'pages/routers.dart';
import 'pages/study/study_model.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// 顶级页面，跟页面相关的全局属性配置/初始化必要的全局信息
class AppPage extends StatelessWidget {
  const AppPage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // 简易模式测试页面
    if (BuildConfig.isTestApp) {
      return _buildEasyApp();
    }

    // 初始化需要用到context的地方，在创建MaterialApp之前
    _useContextBeforeBuild(context);
    // 初始化其他需要context的组件
    // Provider
    // Keyboard
    // 返回键监听
    return _buildProviderApp(
      child: _buildMaterialApp(),
    );
  }

  /// 进入学习页面
  Widget _buildEasyApp() {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }

  /// Provider 共享状态管理
  Widget _buildProviderApp({Widget? child}) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => LocalModel()),
      ChangeNotifierProvider(create: (context) => MainModel()),
      ChangeNotifierProvider(create: (context) => HomeModel()),
      ChangeNotifierProvider(create: (context) => NavModel()),
      ChangeNotifierProvider(create: (context) => MeModel()),
      ChangeNotifierProvider(create: (context) => UserModel()),
      ChangeNotifierProvider(create: (context) => BannerModel()),
      ChangeNotifierProvider(create: (context) => ArticleModel()),
      ChangeNotifierProvider(create: (context) => WebsiteModel()),
      ChangeNotifierProvider(create: (context) => StudyModel()),
    ], child: child);
  }

  /// 全局适配屏幕
  // Widget _buildScreenApp(Widget child) => ScreenUtilInit(
  //       designSize: const Size(414, 896),
  //       minTextAdapt: true,
  //       splitScreenMode: true,
  //       builder: () => child,
  //     );

  /// 初始化需要用到context的地方，在创建MaterialApp之前
  void _useContextBeforeBuild(BuildContext context) {}

  /// 全局设置（主题、语言、屏幕适配、路由设置）
  Widget _buildMaterialApp() {
    AppRouteDelegate delegate = _createRouteDelegate();
    return Consumer<LocalModel>(builder: (ctx, local, widget) {
      // 初始化需要用到context的地方，在创建MaterialApp之后
      Future.delayed(Duration.zero, () {
        BuildContext context = delegate.context;
        Application().context = context;
        _useContextAfterBuild(context);
      });
      // Page必须放在MaterialApp中运行
      AppTheme theme = local.theme;
      return MaterialApp.router(
        title: 'FlutterUI',
        debugShowCheckedModeBanner: false,
        // 设置主题，读取LocalModel的值，改变LocalModel的theme值会通过provider刷新页面
        theme: ThemeData(
          primaryColor: theme.appbar,
          appBarTheme: AppBarTheme(
            backgroundColor: theme.appbar,
            iconTheme: IconThemeData(
              color: theme.white,
            ),
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: theme.appbar,
          ),
          pageTransitionsTheme: const PageTransitionsTheme(builders: {
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          }),
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a blue toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // 设置语言，读取LocalModel的值，改变LocalModel的locale值会通过provider刷新页面
        locale: local.locale,
        // 国际化
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // 国际化语言包
        supportedLocales: const [
          Locale("en"),
          Locale("zh"),
        ],
        // 初始路由
        routerDelegate: delegate,
        routeInformationParser: const AppRouteInfoParser(),
        builder: (context, child) {
          final botToastBuilder = BotToastInit();
          Widget widget = botToastBuilder(context, child);
          widget = MediaQuery(
            //设置文字大小不随系统设置改变
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: widget,
          );
          return widget;
        },
      );
    });
  }

  /// 创建App RouteDelegate
  AppRouteDelegate _createRouteDelegate() {
    return AppRouteDelegate(routers: Routers.routers, initialRoute: _initApp());
  }

  /// 获取第一个页面
  String _initApp() {
    final String route;
    if (SpUtil.getUserLoginState()) {
      route = Routers.main;
    } else {
      route = Routers.login;
    }
    return route;
  }

  /// 初始化需要用到context的地方，在创建MaterialApp之后，使用的是全局的context
  /// 在[Navigator]1.0使用时，是在[MaterialApp.navigatorKey]设置。
  /// 在[Navigator]2.0使用时，是在[AppRouteDelegate.build]设置。
  void _useContextAfterBuild(BuildContext context) {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    CommonDialog.init(context); // 初始化需要context，在这里注册
  }
}
