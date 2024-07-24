import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'consumer_model.dart';

///
/// Created by a0010 on 2023/3/23 09:01
class LifecyclePage extends StatelessWidget {
  static const String _tag = 'LifecyclePage';

  const LifecyclePage({super.key});

  @override
  Widget build(BuildContext context) {
    log('build');
    return ChangeNotifierProvider(
      create: (BuildContext context) => ConsumerModel(),
      child: Scaffold(
        body: Column(children: [
          const CommonBar(title: '标题', centerTitle: true),
          SingleChildScrollView(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(children: [
                  const SizedBox(height: 16),
                  Consumer<ConsumerModel>(builder: (context, model, widget) {
                    log('Consumer Build');
                    return Text('${model.value}');
                  }),
                  const SizedBox(height: 16),
                  MaterialButton(
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: () {
                      // AppRouter.of(context).pushPage(const ChildPage());
                    },
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('进入下一个页面更新值'),
                    ]),
                  ),
                ]),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  void log(String msg) => Log.p(msg, tag: _tag);
}

class ChildPage extends StatelessWidget {
  const ChildPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        const CommonBar(title: '标题', centerTitle: true),
        SingleChildScrollView(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(children: [
                Consumer<ConsumerModel>(builder: (context, model, widget) {
                  return MaterialButton(
                    textColor: Colors.white,
                    color: Colors.blue,
                    onPressed: () {
                      model.increment();
                    },
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('更新值'),
                    ]),
                  );
                }),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }
}
