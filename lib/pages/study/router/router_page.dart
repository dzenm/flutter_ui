import 'package:flutter/material.dart';
import 'package:flutter_ui/base/res/local_model.dart';
import 'package:flutter_ui/base/res/strings.dart';
import 'package:flutter_ui/base/res/theme/app_theme.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:provider/provider.dart';

import 'first_page.dart';

///
/// Created by a0010 on 2023/2/3 16:43
///
/// 路由测试页面
class RouterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RouterPageState();

  static final List<List<String>> list = [
    [
      '进入下一个页面(pop)',
      '测试1',
    ],
    [
      '进入下一个页面(popUntil)',
      '测试1',
      '测试2',
      '测试3',
      '测试4',
    ],
    [
      '进入下一个页面(pushReplacement)',
    ],
    [
      '进入下一个页面(pushAndRemoveUntil)',
      '测试1',
      '测试2',
      '测试3',
      '测试4',
    ],
  ];
}

class _RouterPageState extends State<RouterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).router, style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(children: _buildList()),
      ),
    );
  }

  List<Widget> _buildList() {
    AppTheme appTheme = context.watch<LocalModel>().appTheme;
    List<Widget> widgets = [];
    List<List<String>> list = RouterPage.list;
    for (int i = 0; i < list.length; i++) {
      widgets
        ..add(SizedBox(height: 8))
        ..add(MaterialButton(
          child: _text(list[i][0]),
          textColor: Colors.white,
          color: appTheme.primary,
          onPressed: () => Navigator.push(context, RouteManager.createMaterialRoute(FirstPage(type: i, index: 0))),
        ));
    }
    return widgets;
  }

  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
