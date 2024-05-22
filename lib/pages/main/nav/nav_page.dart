import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../base/base.dart';
import '../../../generated/l10n.dart';
import 'tab_official_page.dart';
import 'tab_plaza_page.dart';
import 'tab_project_page.dart';
import 'tab_qa_page.dart';
import 'tab_tool_page.dart';
import 'tab_tutorial_page.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// 分类页面
class NavPage extends StatelessWidget {
  static const String _tag = 'MePage';

  const NavPage({super.key});

  List<Widget> get _tabItems => [
    const TabPlazaPage(),
    const TabTutorialPage(),
    const TabQAPage(),
    const TabProjectPage(),
    const TabOfficialPage(),
    const TabToolPage(),
  ];

  @override
  Widget build(BuildContext context) {
    log('build');

    AppTheme theme = context.watch<LocalModel>().theme;
    List<String> tabs = [
      S.of(context).plaza,
      S.of(context).tutorial,
      S.of(context).qa,
      S.of(context).project,
      S.of(context).official,
      S.of(context).tool,
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: CommonBar(
          backgroundColor: theme.white,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.dark,
          ),
          toolbarHeight: 48,
          bottom: TabBar(
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: theme.hint,
            labelColor: theme.primaryText,
            indicatorColor: theme.appbar,
            tabs: tabs.map((text) {
              return Tab(text: text);
            }).toList(),
          ),
        ),
        body: TabBarView(
          children: _tabItems.map((tabView) => KeepAliveWrapper(child: tabView)).toList(),
        ),
      ),
    );
  }

  void log(String msg) => Log.p(msg, tag: _tag);
}
