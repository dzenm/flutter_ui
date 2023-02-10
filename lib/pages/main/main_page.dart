import 'package:flutter/material.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/naughty/naughty.dart';
import 'package:flutter_ui/base/widgets/badge_view.dart';
import 'package:flutter_ui/base/widgets/keep_alive_wrapper.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/pages/main/main_model.dart';
import 'package:provider/provider.dart';

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
  static const String _tag = 'MainPage';

  // 页面管理控制器
  final PageController _pageController = PageController(initialPage: 0);

  // 感知生命周期变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    Log.i('didChangeAppLifecycleState: $state', tag: _tag);
  }

  @override
  void initState() {
    super.initState();
    Log.i('initState', tag: _tag);

    WidgetsBinding.instance.addObserver(this);

    Future.delayed(Duration.zero, () {
      Naughty.getInstance
        ..init(context)
        ..show();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.i('didChangeDependencies', tag: _tag);
  }

  @override
  void didUpdateWidget(covariant MainPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    Log.i('didUpdateWidget', tag: _tag);
  }

  @override
  void deactivate() {
    super.deactivate();
    Log.i('deactivate', tag: _tag);
  }

  @override
  void dispose() {
    _pageController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    Log.i('dispose', tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    Log.i('build', tag: _tag);
    context.watch<MainModel>().init(context);

    List<String> titles = context.watch<MainModel>().titles;
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: _buildListPage(titles),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: _buildBottomNavigationBar(titles),
        ),
      ),
    );
  }

  /// Page widget
  List<Widget> _buildListPage(List<String> titles) {
    return [
      KeepAliveWrapper(child: HomePage(title: titles[0])),
      KeepAliveWrapper(child: NavPage(title: titles[1])),
      KeepAliveWrapper(child: MePage(title: titles[2])),
    ];
  }

  /// BottomNavigationBar widget
  List<Widget> _buildBottomNavigationBar(List<String> titles) {
    int index = 0;
    return titles.map((title) {
      return BottomNavigationBarItemView(index: index++, controller: _pageController);
    }).toList(); // bottomNavigation list
  }
}

/// 底部Item布局
class BottomNavigationBarItemView extends StatefulWidget {
  final int index;
  final PageController controller;
  final GestureTapCallback? onTap;

  BottomNavigationBarItemView({
    required this.index,
    required this.controller,
    this.onTap,
  });

  @override
  State<StatefulWidget> createState() => _BottomNavigationBarItemViewState();
}

class _BottomNavigationBarItemViewState extends State<BottomNavigationBarItemView> {
  static const String _tag = 'BottomNavigationBarItemView';

  @override
  Widget build(BuildContext context) {
    int index = widget.index; // item索引
    int badgeCount = context.watch<MainModel>().badgeCount(index); // 图标的数量
    IconData icon = context.watch<MainModel>().icon(index); // item图标
    String title = context.watch<MainModel>().title(index); // item标题
    bool isSelected = context.watch<MainModel>().isSelected(index); // 是否是选中的索引
    Log.d('build: isSelected=$isSelected, index=$index, title=$title, badgeCount=$badgeCount', tag: _tag);

    Color color = isSelected ? Colors.blue : Colors.grey.shade500;
    double width = 56, height = 56;
    // 平分整个宽度
    return Expanded(
      flex: 1,
      // 给item设置点击事件
      child: TapLayout(
        height: height,
        onTap: () {
          if (!isSelected) {
            context.read<MainModel>().updateSelectIndex(index);
            widget.controller.jumpToPage(index);
            // widget.controller.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.ease);
          }
          if (widget.onTap != null) widget.onTap!();
        },
        child: Container(
          width: width,
          height: height,
          child: Stack(alignment: Alignment.center, children: [
            // 图标和文字充满Stack并居中显示
            Positioned.fill(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, color: color, size: 20),
                SizedBox(height: 2),
                Text(title, style: TextStyle(fontSize: 10, color: color)),
              ]),
            ),
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
          ]),
        ),
      ),
    );
  }
}
