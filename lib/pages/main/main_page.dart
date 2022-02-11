import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/naughty/naughty.dart';
import 'package:flutter_ui/base/res/strings.dart';
import 'package:flutter_ui/base/widgets/badge_view.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/pages/main/main_model.dart';

import 'home_page/home_page.dart';
import 'me_page/me_page.dart';
import 'nav_page/nav_page.dart';

// 主页
class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

// 主页的状态
class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  static const String _TAG = 'MainPage';

  // 页面管理控制器
  final PageController _pageController = PageController(initialPage: 0);

  // 选中页面的索引
  int _itemIndex = 0;

  // 感知生命周期变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    Log.d('didChangeAppLifecycleState: $state', tag: _TAG);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    Log.d('initState', tag: _TAG);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.d('didChangeDependencies', tag: _TAG);
  }

  @override
  void didUpdateWidget(covariant MainPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    Log.d('didUpdateWidget', tag: _TAG);
  }

  @override
  void deactivate() {
    super.deactivate();
    Log.d('deactivate', tag: _TAG);
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
    Log.d('dispose', tag: _TAG);
  }

  @override
  Widget build(BuildContext context) {
    Naughty.getInstance.init(context);
    Naughty.getInstance.show();
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          HomePage(S.of(context).home),
          NavPage(S.of(context).nav),
          MePage(S.of(context).me),
        ],
        onPageChanged: (index) => setState(() => _itemIndex = index),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildBottomNavigationBarItemView(
              index: 0,
              title: S.of(context).home,
              icon: Icons.home,
              badgeCount: MainModel.of.homeCount,
            ),
            _buildBottomNavigationBarItemView(
              index: 1,
              title: S.of(context).nav,
              icon: Icons.airplay_rounded,
              badgeCount: MainModel.of.navCount,
            ),
            _buildBottomNavigationBarItemView(
              index: 2,
              title: S.of(context).me,
              icon: Icons.person,
              badgeCount: MainModel.of.meCount,
            ),
          ],
        ),
      ),
    );
  }

  // NavigationBar item
  Widget _buildBottomNavigationBarItemView({
    required int index,
    required String title,
    required IconData icon,
    int badgeCount = 0,
    GestureTapCallback? onTap,
  }) {
    Color color = _itemIndex == index ? Colors.blue : Colors.grey.shade500;
    double width = 56, height = 56;
    // 平分整个宽度
    return Expanded(
      flex: 1,
      // 给item设置点击事件
      child: TapLayout(
        height: height,
        onTap: () {
          if (_itemIndex != index) setState(() => _pageController.jumpToPage(index));
          if (onTap != null) onTap();
        },
        child: Container(
          width: width,
          height: height,
          child: Stack(alignment: Alignment.center, children: [
            // badge固定在右上角
            Positioned(
              width: width / 2,
              height: height,
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [Positioned(left: 16, top: 2, child: BadgeView(count: badgeCount))],
              ),
            ),
            // 图标和文字充满Stack并居中显示
            Positioned.fill(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, color: color, size: 20),
                SizedBox(height: 2),
                Text(title, style: TextStyle(fontSize: 10, color: color)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
