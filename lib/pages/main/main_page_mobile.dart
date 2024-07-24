import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../base/base.dart';
import '../../generated/l10n.dart';
import 'main_model.dart';

///
/// Created by a0010 on 2023/6/29 15:53
///
class MainPageMobile extends StatelessWidget with Logging {
  final List<MainTab> tabs;
  final List<Widget> children;

  MainPageMobile({super.key, required this.tabs, required this.children});

  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    logPage('build');

    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: _buildBody(),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 56,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _buildBottomNavigationBar(context),
        ),
      ),
    );
  }

  List<Widget> _buildBody() {
    List<Widget> list = [];
    for (var child in children) {
      list.add(KeepAliveWrapper(
        child: Selector<MainModel, MainTab>(
          selector: (_, model) => model.selectedTab,
          builder: (context, value, widget) {
            logPage('MainTab build');
            return child;
          },
        ),
      ));
    }
    return list;
  }

  /// BottomNavigationBar widget
  List<Widget> _buildBottomNavigationBar(BuildContext context) {
    List<Widget> list = [];
    for (var tab in tabs) {
      list.add(
        Expanded(
          flex: 1,
          child: BottomNavigationBarItemView(tab: tab, onTap: () => _jumpToPage(context, tab)),
        ),
      );
    }
    return list;
  }

  /// 跳转页面
  void _jumpToPage(BuildContext context, MainTab tab) {
    bool isSelected = context.read<MainModel>().isSelected(tab);
    if (!isSelected) {
      context.read<MainModel>().selectedTab = tab;
      _controller.jumpToPage(tab.index);
    }
  }
}

/// 底部Item布局
class BottomNavigationBarItemView extends StatelessWidget {
  final MainTab tab;
  final void Function()? onTap;

  const BottomNavigationBarItemView({super.key, required this.tab, this.onTap});

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    double width = 56, height = 56;
    return TapLayout(
      foreground: theme.transparent,
      onTap: () => onTap == null ? null : onTap!(),
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

  Widget _buildBadge() {
    return Selector<MainModel, int>(
      builder: (context, value, widget) {
        return BadgeTag(count: value);
      },
      selector: (context, model) => model.badge(tab),
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
