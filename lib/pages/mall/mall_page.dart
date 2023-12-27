import 'package:flutter/material.dart';

import '../../base/base.dart';
import '../../generated/l10n.dart';
import 'mall_router.dart';

/// 商城页面
class MallPage extends StatefulWidget {
  const MallPage({super.key});

  @override
  State<MallPage> createState() => _MallPageState();
}

class _MallPageState extends State<MallPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonBar(
        title: S.of(context).mall,
        actions: [
          IconButton(
            onPressed: () => AppRouter.of(context).push(MallRouter.addOrder),
            icon: const Icon(Icons.add_circle_outline_outlined),
          ),
        ],
      ),
      body: Container(),
    );
  }
}
