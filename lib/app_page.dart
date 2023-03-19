import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/pages/my/study_util.dart';
import 'package:provider/provider.dart';

import 'application.dart';
import 'base/log/build_config.dart';
import 'base/res/local_model.dart';
import 'base/res/strings.dart';
import 'base/res/theme/app_theme.dart';
import 'base/widgets/keyboard/keyboard_root.dart';
import 'base/widgets/will_pop_view.dart';
import 'models/article_model.dart';
import 'models/banner_model.dart';
import 'models/user_model.dart';
import 'models/website_model.dart';
import 'pages/main/home_page/home_model.dart';
import 'pages/main/main_model.dart';
import 'pages/main/me_page/me_model.dart';
import 'pages/main/nav_page/nav_model.dart';
import 'pages/my/my_page.dart';
import 'pages/study/study_model.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// 全局属性配置/初始化必要的全局信息
class AppPage extends StatelessWidget {
  final Widget child;

  const AppPage({required this.child});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    if (BuildConfig.isTestApp) {
      return _easyApp();
    }
    return _providerApp(_rootApp(
      KeyboardRootWidget(
        child: WillPopView(behavior: BackBehavior.background, child: child),
      ),
    ));
  }

  /// Provider 共享状态管理
  Widget _providerApp(Widget child) => MultiProvider(child: child, providers: [
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
      ]);

  /// 全局适配屏幕
  // Widget _screen(Widget child) => ScreenUtilInit(
  //       designSize: const Size(414, 896),
  //       minTextAdapt: true,
  //       splitScreenMode: true,
  //       builder: () => child,
  //     );

  /// 全局设置（主题、语言设置）
  Widget _rootApp(Widget child) => Consumer<LocalModel>(builder: (context, res, widget) {
        // Page必须放在MaterialApp中运行
        AppTheme? theme = res.appTheme;
        return MaterialApp(
          navigatorKey: Application().navigatorKey,
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

  Widget _easyApp() {
    StudyUtil.main();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyPage(title: 'Flutter Demo Home Page'),
    );
  }
}
