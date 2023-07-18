import 'package:flutter/material.dart';

import '../../../base/log/build_config.dart';
import '../../../base/log/log.dart';
import '../../../base/widgets/common_bar.dart';

///
/// Created by a0010 on 2023/3/23 09:01
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
    log('initState');

    Future.delayed(Duration.zero, () => _getData());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    log('didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant FirstPage oldWidget) {
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

  void log(String msg) => BuildConfig.showPageLog ? Log.p(msg, tag: _tag) : null;
}
