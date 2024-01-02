import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_ui/pages/login/login_page.dart';
import 'package:flutter_ui/pages/main/main_page.dart';
import 'package:provider/provider.dart';

import 'application.dart';
import 'base/base.dart';
import 'generated/l10n.dart';
import 'models/article_model.dart';
import 'models/banner_model.dart';
import 'models/user_model.dart';
import 'models/website_model.dart';
import 'pages/main/home/home_model.dart';
import 'pages/main/main_model.dart';
import 'pages/main/me/me_model.dart';
import 'pages/main/nav/nav_model.dart';
import 'pages/mall/order/order_model.dart';
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
    // 初始化需要用到context的地方，在创建MaterialApp之前
    // 初始化其他需要context的组件
    _useContextBeforeBuild(context);

    Widget child;

    if (BuildConfig.isTestApp) {
      // 简易模式测试页面
      child = _buildEasyApp();
    } else {
      child = _buildMaterialApp();
    }

    // Provider
    return GlobalBox(
      child: _buildProviderApp(
        child: child,
      ),
    );
  }

  /// 初始化需要用到context的地方，在创建MaterialApp之前
  void _useContextBeforeBuild(BuildContext context) {}

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
      ChangeNotifierProvider(create: (context) => OrderModel()),
    ], child: child);
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

  /// 全局适配屏幕
  // Widget _buildScreenApp(Widget child) => ScreenUtilInit(
  //       designSize: const Size(414, 896),
  //       minTextAdapt: true,
  //       splitScreenMode: true,
  //       builder: () => child,
  //     );

  /// 全局设置（主题、语言、屏幕适配、路由设置）
  Widget _buildMaterialApp() {
    return Consumer<LocalModel>(builder: (context, locale, widget) {
      if (AppRouter.isNewRouter) {
        return _buildNewRouterApp(locale);
      }
      return _buildOldRouterApp(locale);
    });
  }

  /// 使用 [Router] 1.0
  Widget _buildOldRouterApp(LocalModel locale) {
    // 获取第一个页面
    final Widget child;
    if (SpUtil.getUserLoginState()) {
      child = const MainPage();
    } else {
      child = LoginPage();
    }

    AppRouterOldRegister().initRouter(routers: Routers.routers);

    GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
    // 初始化需要用到context的地方，在创建MaterialApp之后
    Future.delayed(Duration.zero, () {
      BuildContext context = navigatorKey.currentState!.context;
      Application().context = context;
      _useContextAfterBuild(context);
    });
    // Page必须放在MaterialApp中运行
    AppTheme theme = locale.theme;
    return MaterialApp(
      title: 'FlutterUI',
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      // 设置主题，读取LocalModel的值，改变LocalModel的theme值会通过provider刷新页面
      theme: ThemeData(
        primaryColor: theme.appbar,
        appBarTheme: AppBarTheme(
          backgroundColor: theme.appbar,
          iconTheme: IconThemeData(
            color: theme.white,
          ),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
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
      locale: locale.locale,
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
      initialRoute: Routers.root,
      onGenerateRoute: AppRouterOldRegister().generator,
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
  }

  /// 使用 [Router] 2.0
  Widget _buildNewRouterApp(LocalModel locale) {
    AppTheme theme = locale.theme;
    AppRouteDelegate delegate = _createRouteDelegate();
    // 初始化需要用到context的地方，在创建MaterialApp之后
    Future.delayed(Duration.zero, () {
      BuildContext context = delegate.context;
      Application().context = context;
      _useContextAfterBuild(context);
    });
    // Page必须放在MaterialApp中运行
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
          systemOverlayStyle: SystemUiOverlayStyle.dark,
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
      locale: locale.locale,
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
        return MediaQuery(
          //设置文字大小不随系统设置改变
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: BotToastInit()(context, child),
        );
      },
    );
  }

  /// 创建App RouteDelegate
  AppRouteDelegate _createRouteDelegate() {
    // 获取第一个页面
    final String route;
    if (SpUtil.getUserLoginState()) {
      route = Routers.main;
    } else {
      route = Routers.login;
    }
    return AppRouteDelegate(routers: Routers.routers, initialRoute: route);
  }

  /// 初始化需要用到context的地方，在创建MaterialApp之后，使用的是全局的context
  /// 在[Navigator]1.0使用时，是在[MaterialApp.navigatorKey]设置。
  /// 在[Navigator]2.0使用时，是在[AppRouteDelegate.build]设置。
  void _useContextAfterBuild(BuildContext context) {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    CommonDialog.init(context); // 初始化需要context，在这里注册
  }
}
