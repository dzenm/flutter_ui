import 'package:flutter/material.dart';
import 'package:flutter_ui/base/widgets/common_bar.dart';

///
/// Created by a0010 on 2023/3/23 09:01
/// 快速页面创建
class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<StatefulWidget> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(children: [
          CommonBar(title: Text('标题'), centerTitle: true),
        ]),
      ),
    );
  }
}
