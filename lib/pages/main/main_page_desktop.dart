import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../base/log/log.dart';
import '../../base/naughty/naughty.dart';
import '../../base/widgets/keep_alive_wrapper.dart';
import '../../models/provider_manager.dart';
import 'home/home_page.dart';
import 'main_model.dart';
import 'main_page_mobile.dart';
import 'me/me_page.dart';
import 'nav/nav_page.dart';

///
/// Created by a0010 on 2023/6/29 15:49
///
class MainPageDesktop extends StatefulWidget {
  const MainPageDesktop({super.key});

  @override
  State<StatefulWidget> createState() => _MainPageDesktopState();
}

class _MainPageDesktopState extends State<MainPageDesktop> with WidgetsBindingObserver {
  static const String _tag = 'MainPage';

  /// 感知生命周期变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    log('didChangeAppLifecycleState: $state');

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
    log('initState');

    WidgetsBinding.instance.addObserver(this);
    // 先初始化页面
    ProviderManager.main(context: context).init();

    _initData();
  }

  /// 初始化数据
  Future<void> _initData() async {
    log('initData');
    await _initProvider();
  }

  /// 初始化Provider数据，使用context并且异步加载，必须放在页面执行
  Future<void> _initProvider() async {
    log('initProvider');
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
      log('model数据获取完成');
      context.read<MainModel>().initialComplete();
    });
  }

  /// 在[build]之前使用使用[context]初始化数据
  void _useContextBeforeBuild(BuildContext context) {
    Naughty.instance
      ..init(context)
      ..show();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    log('didChangeDependencies');
  }

  @override
  void didUpdateWidget(MainPageDesktop oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('didUpdateWidget');
  }

  @override
  void deactivate() {
    super.deactivate();
    log('deactivate');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
    log('dispose');
  }

  @override
  Widget build(BuildContext context) {
    log('build');

    _useContextBeforeBuild(context);

    int length = context.watch<MainModel>().length;
    PageController controller = context.watch<MainModel>().controller;
    return Scaffold(
      body: PageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        children: _buildTabPage(length),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 56,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _buildBottomNavigationBar(length),
        ),
      ),
    );
  }

  /// Page widget
  List<Widget> _buildTabPage(int length) {
    List<Widget> list = [const HomePage(), NavPage(), const MePage()];
    return List.generate(
      length,
      (index) => KeepAliveWrapper(child: index < list.length ? list[index] : Container()),
    );
  }

  /// BottomNavigationBar widget
  List<Widget> _buildBottomNavigationBar(int length) {
    return List.generate(
      length,
      (i) => Expanded(flex: 1, child: BottomNavigationBarItemView(index: i)),
    ); // bottomNavigation list
  }

  void log(String msg) => Log.p(msg, tag: _tag);
}
