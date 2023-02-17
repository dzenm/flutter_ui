import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/pages/main/me_page/me_model.dart';
import 'package:provider/provider.dart';

import 'model_data_change_page.dart';

///
/// Created by a0010 on 2022/3/30 16:17
///
class ModelDataListenPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ModelDataListenPageState();
}

class _ModelDataListenPageState extends State<ModelDataListenPage> {
  static const String _tag = 'TabPage';

  Person? person;

  @override
  void initState() {
    super.initState();
    Log.i('initState', tag: _tag);
    Future.delayed(Duration.zero, () {
      person = Provider.of<MeModel>(context, listen: false).persons[0];
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.i('didChangeDependencies', tag: _tag);
  }

  @override
  void didUpdateWidget(covariant ModelDataListenPage oldWidget) {
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
    Log.i('page: build', tag: _tag);
    return Scaffold(
      appBar: AppBar(
        title: Text('测试', style: TextStyle(color: Colors.white)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(children: _buildChildrenButtons()),
        ),
      ),
    );
  }

  List<Widget> _buildChildrenButtons() {
    return [
      SizedBox(height: 16),
      MaterialButton(
        child: Text('进入下一个页面'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(context, ModelDataChangePage()),
      ),
      SizedBox(height: 16),
      ParentWidget(),
      SizedBox(height: 16),
      ChildWidget(),
      SizedBox(height: 16),
      _buildMyWidget(),
      SizedBox(height: 16),
      MaterialButton(
        child: Text('修改数据'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () {
          person?.name = '1.修改后的名字';
          person?.age = 32;
          person?.address = '3.修改后的地址';
          context.read<MeModel>().updatePerson(0, person!);
          // Provider.of<MeModel>(context, listen: false).updatePerson(0, person!);
        },
      ),
      SizedBox(height: 16),
      MaterialButton(
        child: Text('修改数据'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () {
        },
      ),
    ];
  }

  Widget _buildMyWidget() {
    Log.i('_myWidget widget: build', tag: _tag);
    // Person person = Provider.of<MeModel>(context, listen: true).persons[0];
    return Column(children: [
      Text('myWidget: ${person?.name}'),
      SizedBox(width: 16),
      Text('myWidget: ${person?.address}'),
      SizedBox(width: 16),
      Text('myWidget: ${person?.age}'),
    ]);
  }
}

class ParentWidget extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget> {

  @override
  Widget build(BuildContext context) {
    Log.i('父widget: build', tag: 'ParentWidget');
    // Person person = Provider.of<MeModel>(context, listen: true).persons[0];
    Person person = context.watch<MeModel>().persons[0];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('父widget: ${person.name}'),
      SizedBox(width: 16),
      Text('父widget: ${person.address}'),
      SizedBox(width: 16),
      Text('父widget: ${person.age}'),
    ]);
  }
}

class ChildWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ChildWidgetState();
}

class _ChildWidgetState extends State<ChildWidget> {

  Person? person;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      // person = Provider.of<MeModel>(context, listen: true).persons[0];
    });
  }

  @override
  Widget build(BuildContext context) {
    Log.i('子widget: build', tag: 'ChildWidget');
    Person person = Provider.of<MeModel>(context, listen: false).persons[0];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('子widget: ${person.name}'),
      SizedBox(width: 16),
      Text('子widget: ${person.address}'),
      SizedBox(width: 16),
      Text('子widget: ${person.age}'),
    ]);
  }
}
