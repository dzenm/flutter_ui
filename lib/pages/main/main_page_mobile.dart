import 'package:flutter/material.dart';
import 'package:flutter_ui/models/provider_manager.dart';
import 'package:provider/provider.dart';

import '../../base/log/build_config.dart';
import '../../base/log/log.dart';
import '../../base/naughty/naughty.dart';
import '../../base/widgets/keep_alive_wrapper.dart';
import 'home_page/home_page.dart';
import 'main_model.dart';
import 'main_page.dart';
import 'me_page/me_page.dart';
import 'nav_page/nav_page.dart';

///
/// Created by a0010 on 2023/6/29 15:53
///
class MainPageMobile extends StatefulWidget {
  const MainPageMobile({super.key});

  @override
  State<StatefulWidget> createState() => _MainPageMobileState();
}

class _MainPageMobileState extends State<MainPageMobile> with WidgetsBindingObserver {
  static const String _tag = 'MainPage';

  // 页面管理控制器
  final PageController _controller = PageController(initialPage: 0);

  // 感知生命周期变化
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
    Future.delayed(Duration.zero, () => _initData());
  }

  /// 初始化数据
  Future<void> _initData() async {
    log('initData');
    await ProviderManager.init(context);
  }

  /// 在[build]之前使用使用[context]初始化数据
  void _useContextBeforeBuild(BuildContext context) {
    ProviderManager.initData(context);
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
  void didUpdateWidget(covariant MainPageMobile oldWidget) {
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
    _controller.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
    log('dispose');
  }

  @override
  Widget build(BuildContext context) {
    log('build');

    _useContextBeforeBuild(context);

    int len = context.read<MainModel>().len;
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: NeverScrollableScrollPhysics(),
        children: _buildTabPage(len),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: _buildBottomNavigationBar(len),
        ),
      ),
    );
  }

  /// Page widget
  List<Widget> _buildTabPage(int len) {
    List<Widget> list = [HomePage(), NavPage(), MePage()];
    return List.generate(
      len,
      (index) => KeepAliveWrapper(child: index < list.length ? list[index] : Container()),
    );
  }

  /// BottomNavigationBar widget
  List<Widget> _buildBottomNavigationBar(int len) {
    return List.generate(
      len,
      (i) => Expanded(
        flex: 1,
        child: BottomNavigationBarItemView(index: i, controller: _controller),
      ),
    ); // bottomNavigation list
  }

  void log(String msg) => BuildConfig.showPageLog ? Log.i(msg, tag: _tag) : null;
}
