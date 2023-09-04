import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/pages/study/provider_page/model_page.dart';
import 'package:flutter_ui/pages/study/study_model.dart';
import 'package:provider/provider.dart';

import '../../../base/log/log.dart';
import '../../../base/route/route_manager.dart';
import 'lifecycle_page.dart';

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

  User? _user;

  @override
  void initState() {
    super.initState();
    log('initState');
    Future.delayed(Duration.zero, () {
      _user = context.read<StudyModel>().getUser(1);
      setState(() {});
    });
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
      MaterialButton(
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () {
          RouteManager.push(context, const ModelPage());
        },
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Selector和Provider监听的变化'),
        ]),
      ),
      const SizedBox(height: 16),
      MaterialButton(
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () {
          RouteManager.push(context, const LifecyclePage());
        },
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Model的生命周期跟随页面'),
        ]),
      ),
    ];
    return [
      const SizedBox(height: 16),
      MaterialButton(
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () {
          RouteManager.push(context, const ModelPage());
        },
        child: const Text('Selector和Provider监听的变化'),
      ),
      const SizedBox(height: 16),
      const Text('监听setState更新UI'),
      const SizedBox(height: 8),
      _buildSetStateWidget(user: _user),
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
            _user?.username = '通过state更新名字';
            _user?.age = 10;
            _user?.address = 'setState Beijing';

            setState(() {});
          },
          child: const Text('setState'),
        ),
        MaterialButton(
          textColor: Colors.white,
          color: Colors.blue,
          onPressed: () {
            // I/ProviderWidget  build
            User? user = context.read<StudyModel>().getUser(2);
            user?.username = '通过Provider更新名字';
            user?.age = 20;
            user?.address = 'Provider Shanghai';
            context.read<StudyModel>().updateUser(user);
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
            User? user = context.read<StudyModel>().getUser(2);
            user?.username = '通过Selector更新名字';
            user?.age = 30;
            user?.address = 'Selector JiangSu';
            context.read<StudyModel>().updateUser(user);
          },
          child: const Text('Selector'),
        ),
      ]),
    ];
  }

  Widget _buildSetStateWidget({User? user}) {
    log('buildSetStateWidget');

    // setState 当前所在的widget及子widget都会被重建
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text('${user?.username}')]),
        const SizedBox(height: 8),
        Row(children: [Text('${user?.address}')]),
        const SizedBox(height: 8),
        Row(children: [Text('${user?.age}')]),
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
          Selector<StudyModel, String>(
            builder: (context, value, widget) {
              log('Selector name: build');

              return Text(value);
            },
            selector: (context, model) => model.getUser(1)?.username ?? '',
          )
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Selector<StudyModel, String>(
            builder: (context, value, widget) {
              log('Selector address: build');

              return Text(value);
            },
            selector: (context, model) => model.getUser(1)?.address ?? '',
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Selector<StudyModel, int>(
            builder: (context, value, widget) {
              log('Selector age: build');

              return Text('$value');
            },
            selector: (context, model) => model.getUser(1)?.age ?? 0,
          ),
        ]),
      ]),
    );
  }

  void log(String msg) => Log.p(msg, tag: _tag);
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
    User? user = context.watch<StudyModel>().getUser(2);
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text('${user?.username}')]),
        const SizedBox(height: 8),
        Row(children: [Text('${user?.address}')]),
        const SizedBox(height: 8),
        Row(children: [Text('${user?.age}')]),
      ]),
    );
  }

  void log(String msg) => Log.p(msg, tag: _tag);
}
