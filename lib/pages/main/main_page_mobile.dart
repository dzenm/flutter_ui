import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../base/res/app_theme.dart';
import '../../base/res/local_model.dart';
import '../../base/widgets/badge_tag.dart';
import '../../base/widgets/keep_alive_wrapper.dart';
import '../../base/widgets/tap_layout.dart';
import '../../generated/l10n.dart';
import 'home/home_page.dart';
import 'main_model.dart';
import 'me/me_page.dart';
import 'nav/nav_page.dart';

///
/// Created by a0010 on 2023/6/29 15:53
///
class MainPageMobile extends StatelessWidget {
  const MainPageMobile({super.key});

  @override
  Widget build(BuildContext context) {
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
