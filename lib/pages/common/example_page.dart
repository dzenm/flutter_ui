import 'package:flutter/material.dart';

import '../../base/widgets/common_bar.dart';

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

    Future.delayed(Duration.zero, () => _getData());
  }

  Future<void> _getData() async {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: const [
        CommonBar(title: '标题', centerTitle: true),
      ]),
    );
  }
}
