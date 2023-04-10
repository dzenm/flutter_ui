import 'package:flutter/material.dart';

import '../../../base/log/log.dart';
import '../../../base/widgets/common_bar.dart';

///
/// Created by a0010 on 2023/3/23 09:01
/// 快速页面创建
class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<StatefulWidget> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  static const String _tag = 'FirstPage';

  @override
  void initState() {
    super.initState();
    Log.i('initState', tag: _tag);

    Future.delayed(Duration.zero, () => _getData());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.i('didChangeDependencies', tag: _tag);
  }

  @override
  void didUpdateWidget(covariant FirstPage oldWidget) {
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

  Future<void> _getData() async {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(children: [
          CommonBar(title: '标题', centerTitle: true),
        ]),
      ),
    );
  }
}
