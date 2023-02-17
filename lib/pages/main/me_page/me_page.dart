import 'package:flutter/material.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/model/local_model.dart';
import 'package:flutter_ui/base/res/strings.dart';
import 'package:flutter_ui/base/res/theme/app_theme.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/utils/device_util.dart';
import 'package:flutter_ui/base/widgets/single_text_layout.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/pages/main/me_page/me_model.dart';
import 'package:flutter_ui/pages/study/setting_page/setting_page.dart';
import 'package:flutter_ui/pages/study/study_page.dart';
import 'package:provider/provider.dart';

import 'medicine_page/chinese_medicine_page.dart';
import 'model_data_listen_page.dart';

// 我的页面
class MePage extends StatefulWidget {
  final String title;

  MePage({required this.title});

  @override
  _MePageState createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  static const String _tag = 'MePage';

  @override
  void initState() {
    super.initState();
    Log.i('initState', tag: _tag);
    Future.delayed(Duration.zero, () => getData());
  }

  void getData() async {
    String ip = await DeviceUtil.getIP();
    context.read<MeModel>().updateIP(ip);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.i('didChangeDependencies', tag: _tag);
  }

  @override
  void didUpdateWidget(covariant MePage oldWidget) {
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
    super.dispose();
    Log.i('dispose', tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    Log.i('build', tag: _tag);

    AppTheme? theme = context.watch<LocalModel>().appTheme;
    double? statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // toolbar背景色块
          Column(children: [
            SizedBox(
              height: statusBarHeight + kToolbarHeight,
              child: Container(color: theme.primary),
            ),
            Expanded(child: Container(color: theme.divide)),
          ]),
          // body
          SingleChildScrollView(
            physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()), // 上拉下拉弹簧效果
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                padding: EdgeInsets.only(top: statusBarHeight + 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.background,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(children: buildChildrenButtons(theme, statusBarHeight)),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // 药
  List<Widget> buildChildrenButtons(AppTheme? theme, double statusBarHeight) {
    String ip = context.watch<MeModel>().ip;
    return [
      SizedBox(height: 8),
      TapLayout(
        height: 50.0,
        padding: EdgeInsets.symmetric(horizontal: 16),
        onTap: () => RouteManager.push(context, ModelDataListenPage()),
        child: SingleTextLayout(
          title: '进入下一个页面',
          isShowForward: true,
        ),
      ),
      SizedBox(height: 8),
      TapLayout(
        height: 50.0,
        padding: EdgeInsets.symmetric(horizontal: 16),
        onTap: () => RouteManager.push(context, ChineseMedicinePage(medicineName: '金银花')),
        child: SingleTextLayout(
          title: 'Chinese Medicine',
          isShowForward: true,
        ),
      ),
      SizedBox(height: 8),
      Text('$ip'),
      SizedBox(height: 8),
      TapLayout(
        height: 50.0,
        padding: EdgeInsets.symmetric(horizontal: 16),
        onTap: () => RouteManager.push(context, StudyPage()),
        child: SingleTextLayout(
          icon: Icons.real_estate_agent_sharp,
          title: '学习主页',
          isShowForward: true,
        ),
      ),
      TapLayout(
        height: 50.0,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
        padding: EdgeInsets.symmetric(horizontal: 16),
        onTap: () => RouteManager.push(context, SettingPage()),
        child: SingleTextLayout(
          icon: Icons.settings,
          title: S.of(context).setting,
          isShowForward: true,
        ),
      ),
    ];
  }
}
