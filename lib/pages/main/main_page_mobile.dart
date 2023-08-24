import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../base/log/log.dart';
import '../../base/naughty/naughty.dart';
import '../../base/res/app_theme.dart';
import '../../base/res/local_model.dart';
import '../../base/widgets/badge_tag.dart';
import '../../base/widgets/keep_alive_wrapper.dart';
import '../../base/widgets/tap_layout.dart';
import '../../generated/l10n.dart';
import '../../models/provider_manager.dart';
import 'home/home_page.dart';
import 'main_model.dart';
import 'me/me_page.dart';
import 'nav/nav_page.dart';

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

/// 底部Item布局
class BottomNavigationBarItemView extends StatelessWidget {
  final int index;

  const BottomNavigationBarItemView({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    double width = 56, height = 56;
    return TapLayout(
      foreground: theme.transparent,
      onTap: () => _jumpToPage(context),
      child: SizedBox(
        width: width,
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
              children: [Positioned(left: 20, top: 8, child: _buildBadge())],
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
        Color color = isSelected ? theme.appbar : theme.hint;
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 20),
          Text(title, style: TextStyle(fontSize: 10, color: color)),
        ]);
      },
      selector: (context, model) => model.selectedIndex,
    );
  }
}
