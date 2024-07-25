import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../models/provider_manager.dart';
import '../utils/notification_util.dart';
import 'home/home_page.dart';
import 'main_model.dart';
import 'main_page_desktop.dart';
import 'main_page_mobile.dart';
import 'me/me_page.dart';
import 'nav/nav_page.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// 主页页面
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with Logging, WidgetsBindingObserver {
  final List<Widget> _pages = [
    const HomePage(),
    const NavPage(),
    const MePage(),
  ];

  /// 感知生命周期变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    logPage('didChangeAppLifecycleState: $state');

    // 处理APP生命周期
    switch (state) {
      case AppLifecycleState.inactive: // 失去焦点
        break;
      case AppLifecycleState.resumed: // 进入前台
        break;
      case AppLifecycleState.paused: // 进入后台
        break;
      default:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    logPage('initState');

    WidgetsBinding.instance.addObserver(this);

    // 先初始化页面
    ProviderManager.main(context: context).init();

    _initData();
  }

  /// 初始化数据
  Future<void> _initData() async {
    logPage('initData');
    await _initProvider();
  }

  /// 初始化Provider数据，使用context并且异步加载，必须放在页面执行
  Future<void> _initProvider() async {
    logInfo('initProvider');

    // 再初始化数据
    await Future.wait([
      // 表相关的Model
      ProviderManager.article(context: context).init(),
      ProviderManager.banner(context: context).init(),
      ProviderManager.user(context: context).init(),
      ProviderManager.website(context: context).init(),

      // 页面相关的Model
      ProviderManager.home(context: context).init(),
      ProviderManager.me(context: context).init(),
      ProviderManager.nav(context: context).init(),
      ProviderManager.study(context: context).init(),
    ]).whenComplete(() {
      // 数据初始化完成进行标记
      logInfo('model数据获取完成');
      context.read<MainModel>().initialComplete();
    });
  }

  /// 在[build]之前使用使用[context]初始化数据
  void _useContextBeforeBuild(BuildContext context) {
    Naughty.instance
      ..init(context, notification: (title, body, onTap) {
        NotificationUtil().showNotification(
          title: title,
          body: body,
          onTap: (s) => onTap(),
        );
      })
      ..show();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    logPage('didChangeDependencies');
  }

  @override
  void didUpdateWidget(MainPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    logPage('didUpdateWidget');
  }

  @override
  void deactivate() {
    super.deactivate();
    logPage('deactivate');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
    logPage('dispose');
  }

  @override
  Widget build(BuildContext context) {
    logPage('build');

    _useContextBeforeBuild(context);

    Map<MainTab, Widget> tabs = {};
    for (var tab in MainTab.values) {
      tabs[tab] = _pages[tab.index];
    }
    if (BuildConfig.isMobile) {
      return MainPageMobile(tabs: tabs);
    } else if (BuildConfig.isWeb) {
      return MainPageDesktopWrapper(
        child: MainPageDesktop(tabs: tabs),
      );
    } else if (BuildConfig.isDesktop) {
      return MainPageDesktopWrapper(
        child: MainPageDesktop(tabs: tabs),
      );
    }
    return Center(
      child: Text(S.of(context).unknownPlatform),
    );
  }
}
