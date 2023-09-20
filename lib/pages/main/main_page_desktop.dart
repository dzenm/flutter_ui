import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../base/res/app_theme.dart';
import '../../base/res/local_model.dart';
import '../../base/widgets/keep_alive_wrapper.dart';
import '../../generated/l10n.dart';
import 'home/home_page.dart';
import 'main_model.dart';
import 'me/me_page.dart';
import 'nav/nav_page.dart';

///
/// Created by a0010 on 2023/6/29 15:49
///
class MainPageDesktop extends StatelessWidget {
  const MainPageDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    int length = context.watch<MainModel>().length;
    int selectedIndex = context.watch<MainModel>().selectedIndex;
    return Scaffold(
      body: Container(
        color: Colors.transparent,
        child: Row(children: [
          NavigationRail(
            minWidth: 56.0,
            selectedIndex: selectedIndex,
            onDestinationSelected: (int index) {
              context.read<MainModel>().selectedIndex = index;
            },
            labelType: NavigationRailLabelType.all,
            destinations: _buildNavigationRailItem(context, length, selectedIndex),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // 主要的展示内容，Expanded 占满剩下屏幕空间
          Expanded(child: _buildTabPage(length)[selectedIndex])
        ]),
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

  List<NavigationRailDestination> _buildNavigationRailItem(BuildContext context, int length, int selectedIndex) {
    return List.generate(
      length,
      (index) {
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
        AppTheme theme = context.watch<LocalModel>().theme;
        IconData icon = icons[index]; // 图标
        String title = titles[index]; // 标题
        bool isSelected = index == index; // 是否是选中的索引
        Color color = isSelected ? theme.appbar : theme.hint;
        return NavigationRailDestination(
          icon: Icon(icon, color: color),
          selectedIcon: Icon(icon, color: color),
          label: Text(title),
        );
      },
    );
  }
}
