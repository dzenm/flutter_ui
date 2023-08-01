import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../base/log/build_config.dart';
import '../../../base/log/log.dart';
import '../../main/me/me_model.dart';

///
/// Created by a0010 on 2023/3/2 15:11
/// Provider
class ProviderPage extends StatefulWidget {
  const ProviderPage({super.key});

  @override
  State<StatefulWidget> createState() => _ProviderPageState();
}

class _ProviderPageState extends State<ProviderPage> {
  static const String _tag = 'ProviderPage';

  Person? person;

  @override
  void initState() {
    super.initState();
    log('initState');
    Future.delayed(Duration.zero, () {
      person = context.read<MeModel>().persons.first;
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    log('didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant ProviderPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('didUpdateWidget');
  }

  @override
  void deactivate() {
    super.deactivate();
    log('deactivate');
  }

  @override
  void dispose() {
    super.dispose();
    log('dispose');
  }

  @override
  Widget build(BuildContext context) {
    log('build');

    return Scaffold(
      appBar: AppBar(
        title: const Text('测试Provider', style: TextStyle(color: Colors.white)),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildChildrenButtons(),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  List<Widget> _buildChildrenButtons() {
    return [
      const SizedBox(height: 16),
      const Text('监听setState更新UI'),
      const SizedBox(height: 8),
      _buildSetStateWidget(person: person),
      const SizedBox(height: 16),
      const Text('监听Provider更新UI'),
      const SizedBox(height: 8),
      _ProviderWidget(),
      const SizedBox(height: 16),
      const Text('监听Selector更新UI'),
      const SizedBox(height: 8),
      _buildSelectorWidget(),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        MaterialButton(
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: () {
            // I/ProviderPage  build
            // I/ProviderPage  buildSetStateWidget
            // I/ProviderPage  buildSelectorWidget
            // I/ProviderWidget  build
            // I/ProviderPage  Selector name: build
            // I/ProviderPage  Selector address: build
            // I/ProviderPage  Selector age: build
            person?.name = '通过state更新名字';
            person?.age = 10;
            person?.address = 'setState Beijing';

            setState(() {});
          },
          child: const Text('setState'),
        ),
        MaterialButton(
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: () {
            // I/ProviderWidget  build
            Person person = context.read<MeModel>().persons[1];
            person.name = '通过Provider更新名字';
            person.age = 20;
            person.address = 'Provider Shanghai';
            context.read<MeModel>().updatePerson(1, person);
          },
          child: const Text('Provider'),
        ),
        MaterialButton(
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: () {
            // I/ProviderWidget  build
            // I/ProviderPage  Selector name: build
            // I/ProviderPage  Selector age: build
            // I/ProviderPage  Selector address: build
            Person person = context.read<MeModel>().persons.last;
            person.name = '通过Selector更新名字';
            person.age = 30;
            person.address = 'Selector JiangSu';
            context.read<MeModel>().updatePerson(2, person);
          },
          child: const Text('Selector'),
        ),
      ]),
    ];
  }

  Widget _buildSetStateWidget({Person? person}) {
    log('buildSetStateWidget');

    // setState 当前所在的widget及子widget都会被重建
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text('${person?.name}')]),
        const SizedBox(height: 8),
        Row(children: [Text('${person?.address}')]),
        const SizedBox(height: 8),
        Row(children: [Text('${person?.age}')]),
      ]),
    );
  }

  Widget _buildSelectorWidget() {
    log('buildSelectorWidget');

    // Selector 只在监听的值改变后发生变化，如果该值未改变，或者对象中的其他值/List的其他index值改变，均不会受到影响
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Selector<MeModel, String>(
            builder: (context, value, widget) {
              log('Selector name: build');

              return Text(value);
            },
            selector: (context, model) => model.persons.last.name ?? '',
          )
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Selector<MeModel, String>(
            builder: (context, value, widget) {
              log('Selector address: build');

              return Text(value);
            },
            selector: (context, model) => model.persons.last.address ?? '',
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Selector<MeModel, int>(
            builder: (context, value, widget) {
              log('Selector age: build');

              return Text('$value');
            },
            selector: (context, model) => model.persons.last.age ?? 0,
          ),
        ]),
      ]),
    );
  }

  void log(String msg) => BuildConfig.showPageLog ? Log.p(msg, tag: _tag) : null;

}

class _ProviderWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProviderWidgetState();
}

class _ProviderWidgetState extends State<_ProviderWidget> {
  static const String _tag = 'ProviderWidget';

  @override
  Widget build(BuildContext context) {
    log('build');

    // watch 当前widget存在监听的对象有任一细微的变化都会影响build及子widget进行重建
    // 比如监听的是List或者List的其中一个item，如果List的其他item发生变化都会影响监听了List或者List的其中一个item的widget进行重建
    Person person = context.watch<MeModel>().persons[1];
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text('${person.name}')]),
        const SizedBox(height: 8),
        Row(children: [Text('${person.address}')]),
        const SizedBox(height: 8),
        Row(children: [Text('${person.age}')]),
      ]),
    );
  }

  void log(String msg) => BuildConfig.showPageLog ? Log.p(msg, tag: _tag) : null;
}
