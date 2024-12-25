import 'package:dbl/dbl.dart';
import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/pages/desktop_service.dart';
import 'package:provider/provider.dart';

import '../common/view_media.dart';
import 'main_model.dart';

///
/// Created by a0010 on 2023/6/29 15:49
///
class MainPageDesktop extends StatefulWidget {
  final StatefulNavigationShell navigationShell;
  final PageController controller;
  final Map<MainTab, Widget> tabs;

  const MainPageDesktop({
    super.key,
    required this.navigationShell,
    required this.controller,
    required this.tabs,
  });

  @override
  State<MainPageDesktop> createState() => _MainPageDesktopState();
}

class _MainPageDesktopState extends State<MainPageDesktop> with Logging {
  @override
  void initState() {
    super.initState();
    DesktopService().register();
  }

  @override
  void dispose() {
    super.dispose();
    DesktopService().unregister();
  }

  @override
  Widget build(BuildContext context) {
    logPage('build');
    return Material(
      color: Colors.white,
      child: DesktopWrapper(
        child: Row(children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: DesktopNavigationRail(
              width: 56.0,
              onSelected: (int index) {
                _jumpToPage(context, MainTab.parse(index));
              },
              leading: _buildLeadingView(context),
              children: widget.tabs.keys.map((tab) {
                return NavigationRailItemView(tab: tab);
              }).toList(),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // 主要的展示内容，Expanded 占满剩下屏幕空间
          Expanded(
            child: PageView(
              controller: widget.controller,
              physics: const NeverScrollableScrollPhysics(),
              children: _buildBody(),
            ),
          )
        ]),
      ),
    );
  }

  List<Widget> _buildBody() {
    List<Widget> list = [];
    for (var child in widget.tabs.values) {
      list.add(KeepAliveWrapper(child: child));
    }
    return list;
  }

  Widget _buildLeadingView(BuildContext context) {
    String heroTag = 'heroTag';
    List<String> urls = [
      Assets.a,
    ];
    List<MediaEntity> images = urls.map((url) => MediaEntity(url: url)).toList();
    return TapLayout(
      border: Border.all(width: 3.0, color: const Color(0xfffcfcfc)),
      borderRadius: const BorderRadius.all(Radius.circular(32)),
      onTap: () => ViewMediaPage.show(context, medias: images, tag: images),
      child: Hero(
        tag: heroTag,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Image.asset(Assets.a, fit: BoxFit.cover, width: 32, height: 32),
        ),
      ),
    );
  }

  /// 跳转页面
  void _jumpToPage(BuildContext context, MainTab tab) {
    bool isSelected = context.read<MainModel>().isSelected(tab);
    if (!isSelected) {
      context.read<MainModel>().setSelectedTab(tab);
      int index = tab.index;
      widget.controller.jumpToPage(index);
      widget.navigationShell.goBranch(
        index,
        // A common pattern when using bottom navigation bars is to support
        // navigating to the initial location when tapping the item that is
        // already active. This example demonstrates how to support this behavior,
        // using the initialLocation parameter of goBranch.
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    }
  }
}

class NavigationRailItemView extends StatelessWidget {
  final MainTab tab;

  const NavigationRailItemView({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    MainTab selectedTab = context.watch<MainModel>().selectedTab;

    List<IconData> icons = [
      Icons.home,
      Icons.airplay_rounded,
      Icons.person,
    ];
    // List<String> titles = [
    //   S.of(context).home,
    //   S.of(context).nav,
    //   S.of(context).me,
    // ];
    int index = tab.index;
    AppTheme theme = context.watch<LocalModel>().theme;
    IconData icon = icons[index]; // 图标
    // String title = titles[index]; // 标题
    bool isSelected = selectedTab == tab; // 是否是选中的索引
    Color color = isSelected ? theme.appbar : theme.hint;
    return Icon(icon, color: color);
  }
}
