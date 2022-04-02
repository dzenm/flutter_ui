import 'package:flutter/material.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/pages/main/me_page/me_model.dart';
import 'package:provider/provider.dart';

import 'test_page.dart';

///
/// Created by a0010 on 2022/3/30 16:17
///

class TabPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> {
  static const String _TAG = 'TabPage';

  @override
  void initState() {
    super.initState();
    Log.d('initState', tag: _TAG);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.d('didChangeDependencies', tag: _TAG);
  }

  @override
  void didUpdateWidget(covariant TabPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    Log.d('didUpdateWidget', tag: _TAG);
  }

  @override
  void deactivate() {
    super.deactivate();
    Log.d('deactivate', tag: _TAG);
  }

  @override
  void dispose() {
    super.dispose();
    Log.d('dispose', tag: _TAG);
  }

  @override
  Widget build(BuildContext context) {
    Log.d('page: build', tag: _TAG);
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text('测试', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(children: childrenButtons()),
        ),
      ),
    );
  }

  List<Widget> childrenButtons() {
    return [
      SizedBox(height: 16),
      MaterialButton(
        child: Text('进入下一个页面'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(TestPage()),
      ),
      SizedBox(height: 16),
      ParentWidget(),
      SizedBox(height: 16),
      ChildWidget(),
      SizedBox(height: 16),
      MaterialButton(
        child: Text('初始化'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () {
          context.read<MeModel>().setMap({
            'parent1': 'parent init',
            'parent2': 'parent init',
            'child1': 'child1 init',
            'child2': 'child2 init',
          });
        },
      ),
      SizedBox(height: 16),
      MaterialButton(
        child: Text('修改数据'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () {
          context.read<MeModel>().setChildValue('child修改数据');
        },
      ),
    ];
  }
}

class ParentWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {
  @override
  Widget build(BuildContext context) {
    Log.d('父widget: build', tag: 'ParentWidget');
    return Row(children: [
      Text('父widget1: ${context.select<MeModel, String>((model) => model.entity['parent1'])}'),
      Text('父widget2: ${context.select<MeModel, String>((model) => model.entity['parent2'])}'),
    ]);
  }
}

class ChildWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChildWidgetState();
}

class _ChildWidgetState extends State<ChildWidget> {
  @override
  Widget build(BuildContext context) {
    Log.d('子widget: build', tag: 'ChildWidget');
    Map<String, dynamic> map = context.select<MeModel, Map<String, dynamic>>((model) => model.entity);
    return Row(children: [
      Text('子widget1: ${map['child1']}'),
      Text('子widget2: ${map['child2']}'),
    ]);
  }
}
