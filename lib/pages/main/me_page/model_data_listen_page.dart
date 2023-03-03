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
      person = Provider.of<MeModel>(context, listen: false).persons.first;
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
    Log.i('build', tag: _tag);

    return Scaffold(
      appBar: AppBar(
        title: Text('测试', style: TextStyle(color: Colors.white)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _buildChildrenButtons()))]),
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
      ListenerWidget(),
      SizedBox(height: 16),
      UnListenerWidget(),
      SizedBox(height: 16),
      _buildMyWidget(),
      SizedBox(height: 16),
      _buildProviderWidget(),
      SizedBox(height: 16),
      MaterialButton(
        child: Text('通过Provider更新数据'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () {
          person?.name = '在$_tag通过Provider更新Person的名字';
          person?.age = 21;
          person?.address = '在$_tag通过Provider更新Person的地址';
          context.read<MeModel>().updatePerson(0, person!);
        },
      ),
      SizedBox(height: 16),
      MaterialButton(
        child: Text('通过setState更新$_tag数据'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () {
          person?.name = '在$_tag通过setState更新Person的名字';
          person?.age = 31;
          person?.address = '在$_tag更新setState更新Person的地址';
          setState(() {});
        },
      ),
    ];
  }

  Widget _buildMyWidget({Person? person}) {
    Log.i('setState: build', tag: _tag);
    String title = 'setState';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$title: ${person?.name}'),
      SizedBox(width: 16),
      Text('$title: ${person?.address}'),
      SizedBox(width: 16),
      Text('$title: ${person?.age}'),
    ]);
  }

  Widget _buildProviderWidget() {
    String title = 'Provider';
    return Selector<MeModel, Person>(builder: (context, value, widget) {
      Log.i('Provider Selector: build', tag: _tag);
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$title: ${value.name}'),
        SizedBox(width: 16),
        Text('$title: ${value.address}'),
        SizedBox(width: 16),
        Text('$title: ${value.age}'),
      ]);
    }, selector: (context, model) {
      return model.persons.first;
    });
  }
}

class ListenerWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListenerWidgetState();
}

class _ListenerWidgetState extends State<ListenerWidget> {
  static const String _tag = 'ListenerWidget';

  @override
  void initState() {
    super.initState();
    Log.i('initState', tag: _tag);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.i('didChangeDependencies', tag: _tag);
  }

  @override
  void didUpdateWidget(covariant ListenerWidget oldWidget) {
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

    Person person = context.watch<MeModel>().persons.first;
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$_tag: ${person.name}'),
          Text('$_tag: ${person.address}'),
          Text('$_tag: ${person.age}'),
          SizedBox(height: 8),
          MaterialButton(
            child: Text('通过Provider更新数据'),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () {
              person.name = '在$_tag通过Provider更新Person的名字';
              person.age = 21;
              person.address = '在$_tag通过Provider更新Person的地址';
              context.read<MeModel>().updatePerson(0, person);
            },
          ),
          SizedBox(height: 16),
          MaterialButton(
            child: Text('通过setState更新$_tag数据'),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () {
              person.name = '在$_tag通过setState更新Person的名字';
              person.age = 31;
              person.address = '在$_tag更新setState更新Person的地址';
              setState(() {});
            },
          ),
        ]),
      ),
    ]);
  }
}

class UnListenerWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UnListenerWidgetState();
}

class _UnListenerWidgetState extends State<UnListenerWidget> {
  static const String _tag = 'UnListenerWidget';

  @override
  void initState() {
    super.initState();
    Log.i('initState', tag: _tag);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.i('didChangeDependencies', tag: _tag);
  }

  @override
  void didUpdateWidget(covariant UnListenerWidget oldWidget) {
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

    Person person = context.read<MeModel>().persons.first;
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$_tag: ${person.name}'),
          SizedBox(width: 16),
          Text('$_tag: ${person.address}'),
          SizedBox(width: 16),
          Text('$_tag: ${person.age}'),
          SizedBox(width: 16),
          MaterialButton(
            child: Text('通过Provider更新数据'),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () {
              person.name = '在$_tag通过Provider更新Person的名字';
              person.age = 22;
              person.address = '在$_tag通过Provider更新Person的地址';
              context.read<MeModel>().updatePerson(0, person);
            },
          ),
          SizedBox(height: 16),
          MaterialButton(
            child: Text('通过setState更新$_tag数据'),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () {
              person.name = '在$_tag通过setState更新Person的名字';
              person.age = 32;
              person.address = '在$_tag更新setState更新Person的地址';
              setState(() {});
            },
          ),
        ]),
      ),
    ]);
  }
}

class _NameView extends StatelessWidget {
  static const _tag = 'NameView';
  @override
  Widget build(BuildContext context) {
    return Selector<MeModel, String>(builder: (context, value, widget) {
      Log.i('build', tag: _tag);
      return Text('$_tag: $value');
    }, selector: (context, model) {
      return model.persons.first.name ?? '';
    });
  }
}
