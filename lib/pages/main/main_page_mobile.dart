import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../base/base.dart';
import '../../generated/l10n.dart';
import 'main_model.dart';

///
/// Created by a0010 on 2023/6/29 15:53
///
class MainPageMobile extends StatelessWidget {
  final List<MainTab> tabs;
  final List<Widget> children;

  const MainPageMobile({super.key, required this.tabs, required this.children});

  static const String _tag = 'MainPageMobile';

  @override
  Widget build(BuildContext context) {
    _log('build');

    PageController? controller = context.watch<MainModel>().controller;
    if (controller == null) return Container();
    return Scaffold(
      body: PageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        children: children.map((child) => KeepAliveWrapper(child: child)).toList(),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 56,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _buildBottomNavigationBar(),
        ),
      ),
    );
  }

  /// BottomNavigationBar widget
  List<Widget> _buildBottomNavigationBar() {
    return tabs.map(
      (tab) {
        return Expanded(flex: 1, child: BottomNavigationBarItemView(tab: tab));
      },
    ).toList();
  }

  void _log(String msg) => BuildConfig.isDebug ? Log.p(msg, tag: _tag) : null;
}

/// 底部Item布局
class BottomNavigationBarItemView extends StatelessWidget {
  final MainTab tab;

  const BottomNavigationBarItemView({super.key, required this.tab});

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
    bool isSelected = context.read<MainModel>().isSelected(tab);
    if (!isSelected) {
      context.read<MainModel>().selectedTab = tab;
    }
  }

  Widget _buildBadge() {
    return Selector<MainModel, int>(
      builder: (context, value, widget) {
        return BadgeTag(count: value);
      },
      selector: (context, model) => model.badge(tab.index),
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
    int index = tab.index;
    IconData icon = icons[index]; // 图标
    String title = titles[index]; // 标题
    return Selector<MainModel, MainTab>(
      builder: (context, selectedTab, widget) {
        bool isSelected = selectedTab == tab; // 是否是选中的索引
        Color color = isSelected ? theme.appbar : theme.hint;
        return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 20),
          Text(title, style: TextStyle(fontSize: 10, color: color)),
        ]);
      },
      selector: (context, model) => model.selectedTab,
    );
  }
}
