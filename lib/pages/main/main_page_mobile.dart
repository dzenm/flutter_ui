import 'package:flutter/material.dart';
import 'package:flutter_ui/base/res/app_theme.dart';
import 'package:flutter_ui/base/res/local_model.dart';
import 'package:flutter_ui/models/provider_manager.dart';
import 'package:provider/provider.dart';

import '../../base/log/build_config.dart';
import '../../base/log/log.dart';
import '../../base/naughty/naughty.dart';
import '../../base/widgets/badge_tag.dart';
import '../../base/widgets/keep_alive_wrapper.dart';
import '../../base/widgets/tap_layout.dart';
import '../../generated/l10n.dart';
import 'home_page/home_page.dart';
import 'main_model.dart';
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
    context.read<MainModel>().initController(controller: PageController(initialPage: 0));
    Future.delayed(Duration.zero, () => _initData());
  }

  /// 初始化数据
  Future<void> _initData() async {
    log('initData');
    await _initProvider();
  }

  /// 初始化Provider数据，使用context并且异步加载，必须放在页面执行
  Future<void> _initProvider() async {
    // 表相关的Model
    await ProviderManager.article(context: context).init();
    await ProviderManager.banner(context: context).init();
    await ProviderManager.user(context: context).init();
    await ProviderManager.website(context: context).init();

    // 页面相关的Model
    await ProviderManager.main(context: context).init();
    await ProviderManager.home(context: context).init();
    await ProviderManager.me(context: context).init();
    await ProviderManager.nav(context: context).init();
    await ProviderManager.study(context: context).init();
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
    context.read<MainModel>().controller.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
    log('dispose');
  }

  @override
  Widget build(BuildContext context) {
    log('build');

    _useContextBeforeBuild(context);

    int length = context.read<MainModel>().length;
    PageController controller = context.read<MainModel>().controller;
    return Scaffold(
      body: PageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        children: _buildTabPage(length),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: _buildBottomNavigationBar(length),
        ),
      ),
    );
  }

  /// Page widget
  List<Widget> _buildTabPage(int length) {
    List<Widget> list = [const HomePage(), const NavPage(), const MePage()];
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

  void log(String msg) => BuildConfig.showPageLog ? Log.p(msg, tag: _tag) : null;
}

/// 底部Item布局
class BottomNavigationBarItemView extends StatelessWidget {
  final int index;

  const BottomNavigationBarItemView({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    double width = 56, height = 56;
    return TapLayout(
      height: height,
      foreground: theme.transparent,
      onTap: () => _jumpToPage(context),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(alignment: Alignment.center, children: [
          // 图标和文字充满Stack并居中显示
          Positioned.fill(child: _builtItem(context)),
          // badge固定在右上角
          Positioned(
            width: width / 2,
            height: height,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [Positioned(left: 16, top: 2, child: _buildBadge())],
            ),
          ),
        ]),
      ),
    );
  }

  /// 跳转页面
  void _jumpToPage(BuildContext context) {
    bool isSelected = context.read<MainModel>().isSelected(index);
    if (!isSelected) {
      context.read<MainModel>().selectedIndex = index;
    }
  }

  Widget _buildBadge() {
    return Selector<MainModel, int>(
      builder: (context, value, widget) {
        return BadgeTag(count: value);
      },
      selector: (context, model) => model.badge(index),
    );
  }

  Widget _builtItem(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    List<IconData> icons = [
      Icons.home,
      Icons.airplay_rounded,
      Icons.person,
    ];
    List<String> titles = [
      S.of(context).home,
      S.of(context).nav,
      S.of(context).me,
    ];
    IconData icon = icons[index]; // 图标
    String title = titles[index]; // 标题
    return Selector<MainModel, int>(
      builder: (context, value, widget) {
        bool isSelected = value == index; // 是否是选中的索引
        Color color = isSelected ? theme.blue : theme.hint;
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 10, color: color)),
        ]);
      },
      selector: (context, model) => model.selectedIndex,
    );
  }
}
