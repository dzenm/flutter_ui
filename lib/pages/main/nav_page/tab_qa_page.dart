import 'package:flutter/material.dart';

import '../../../http/http_manager.dart';

///
/// Created by a0010 on 2023/7/21 13:14
///
class TabQAPage extends StatefulWidget {
  const TabQAPage({super.key});

  @override
  State<StatefulWidget> createState() => _TabQAPageState();
}

class _TabQAPageState extends State<TabQAPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  Future<void> _getTopArticle() async {
    await HttpManager.instance.getQuestions(
      isShowDialog: false,
      success: (list) {},
    );
  }
}
