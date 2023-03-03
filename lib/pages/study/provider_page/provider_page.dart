import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/pages/main/me_page/me_model.dart';
import 'package:provider/provider.dart';

///
/// Created by a0010 on 2023/3/2 15:11
///
class ProviderPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProviderPageState();
}

class _ProviderPageState extends State<ProviderPage> {
  static const String _tag = 'ProviderPage';

  Person? person;

  @override
  void initState() {
    super.initState();
    Log.i('initState', tag: _tag);
    Future.delayed(Duration.zero, () {
      person = context.read<MeModel>().persons.first;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.i('didChangeDependencies', tag: _tag);
  }

  @override
  void didUpdateWidget(covariant ProviderPage oldWidget) {
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
        title: Text('测试Provider', style: TextStyle(color: Colors.white)),
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
      _buildMyWidget(person: person),
      SizedBox(height: 16),
      _buildProviderWidget(),
      SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        MaterialButton(
          child: Text('Provider更新'),
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: () {
            person?.name = '通过Provider更新名字';
            person?.age = 20;
            person?.address = '通过Provider更新地址';
            context.read<MeModel>().updatePerson(0, person!);
          },
        ),
        MaterialButton(
          child: Text('setState更新'),
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: () {
            person?.name = '通过state更新名字';
            person?.age = 30;
            person?.address = '通过state更新名字';
            setState(() {});
          },
        ),
      ]),
    ];
  }

  Widget _buildMyWidget({Person? person}) {
    Log.i('_buildMyWidget', tag: _tag);
    String title = 'setState';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$title: ${person?.name}'),
      Text('$title: ${person?.address}'),
      Text('$title: ${person?.age}'),
    ]);
  }

  Widget _buildProviderWidget() {
    Log.i('_buildProviderWidget', tag: _tag);
    String title = 'Provider';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Selector<MeModel, String>(
        builder: (context, value, widget) {
          Log.i('Provider Selector name: build', tag: _tag);
          return Text('$title: $value');
        },
        selector: (context, model) => model.persons.first.name ?? '',
      ),
      Selector<MeModel, String>(
        builder: (context, value, widget) {
          Log.i('Provider Selector address: build', tag: _tag);
          return Text('$title: $value');
        },
        selector: (context, model) => model.persons.first.address ?? '',
      ),
      Selector<MeModel, int>(
        builder: (context, value, widget) {
          Log.i('Provider Selector age: build', tag: _tag);
          return Text('$title: $value');
        },
        selector: (context, model) => model.persons.first.age ?? 0,
      ),
    ]);
  }
}
