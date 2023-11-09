import 'package:flutter/material.dart';

import '../../../base/base.dart';

/// 订单页面
class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonBar(title: '订单',),
      body: Container(
      ),
    );
  }
}
