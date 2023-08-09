import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../base/res/app_theme.dart';
import '../../../base/res/local_model.dart';
import '../../../base/widgets/common_bar.dart';
import '../../../base/widgets/keep_alive_wrapper.dart';
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
  NavPage({super.key});

  final List<Widget> _tabItems = [
    const TabPlazaPage(),
    const TabTutorialPage(),
    const TabQAPage(),
    const TabProjectPage(),
    const TabOfficialPage(),
    const TabToolPage(),
  ];

  @override
  Widget build(BuildContext context) {
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
            indicatorColor: theme.accent,
            tabs: tabs.map((text) {
              return Tab(text: text);
            }).toList(),
          ),
        ),
        body: KeepAliveWrapper(
          child: TabBarView(children: _tabItems),
        ),
      ),
    );
  }
}
