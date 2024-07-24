import 'package:flutter/material.dart';

import 'package:fbl/fbl.dart';
import '../../../generated/l10n.dart';

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
      appBar: CommonBar(title: S.of(context).order,),
      body: Container(
      ),
    );
  }
}
