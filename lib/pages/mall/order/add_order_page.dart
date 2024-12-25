import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';

import '../mall_router.dart';

/// 订单页面
class AddOrderPage extends StatefulWidget {
  const AddOrderPage({super.key});

  @override
  State<AddOrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<AddOrderPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonBar(
        title: '创建订单',
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(MallRouter.addAddress),
            icon: const Icon(Icons.add_circle_outline_outlined),
          ),
        ],
      ),
    );
  }
}
