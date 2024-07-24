import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///
/// Created by a0010 on 2023/2/3 16:43
///
/// 路由测试页面
class RouterPage extends StatelessWidget {
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

  const RouterPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return Scaffold(
      appBar: const CommonBar(
        title: '路由跳转',
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(children: _buildList(context, theme)),
      ),
    );
  }

  List<Widget> _buildList(BuildContext context, AppTheme theme) {
    List<Widget> widgets = [];
    List<List<String>> list = RouterPage.list;
    for (int i = 0; i < list.length; i++) {
      widgets
        ..add(const SizedBox(height: 8))
        ..add(MaterialButton(
          textColor: Colors.white,
          color: theme.button,
          onPressed: () => {},
          // onPressed: () => Navigator.push(context, AppRouterOldDelegate.of(context).createMaterialRoute(FirstPage(type: i, index: 0))),
          child: _text(list[i][0]),
        ));
    }
    return widgets;
  }

  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
