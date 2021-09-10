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

// 主页
class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

// 主页的状态
class _MainPageState extends State<MainPage> {
  String _tag = 'MainPage';

  // 页面管理控制器
  final PageController _pageController = PageController(initialPage: 0);

  // 选中页面的索引
  int _itemIndex = 0;

  @override
  void initState() {
    super.initState();
    Log.d('initState', tag: _tag);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.d('didChangeDependencies', tag: _tag);
  }

  @override
  void didUpdateWidget(covariant MainPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    Log.d('didUpdateWidget', tag: _tag);
  }

  @override
  void deactivate() {
    super.deactivate();
    Log.d('deactivate', tag: _tag);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
    Log.d('dispose', tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    Naughty.getInstance.init(context);
    Naughty.getInstance.show();
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [HomePage(S.of.home), MePage(S.of.me)],
        onPageChanged: (int index) => setState(() => _itemIndex = index),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
            _bottomAppBarItemView(Icons.home, S.of.home, 0, badgeCount: MainModel.of.homeCount),
            _bottomAppBarItemView(Icons.person, S.of.me, 1, badgeCount: MainModel.of.meCount),
          ],
        ),
      ),
    );
  }

  // 底部app bar item
  Widget _bottomAppBarItemView(IconData icon, String title, int index, {int badgeCount = 0}) {
    Color color = _itemIndex == index ? Colors.blue : Colors.grey.shade500;
    double width = 56, height = 56;
    // 平分整个宽度
    return Expanded(
      flex: 1,
      // 给item设置点击事件
      child: TapLayout(
        height: height,
        onTap: () => setState(() {
          if (_itemIndex != index) _pageController.jumpToPage(index);
        }),
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
