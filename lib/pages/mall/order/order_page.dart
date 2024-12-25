import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/entities/entity.dart';
import 'package:flutter_ui/pages/mall/order/order_model.dart';
import 'package:provider/provider.dart';

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
      appBar: CommonBar(
        title: S.of(context).order,
      ),
      body: Container(
        child: _buildListView(),
      ),
    );
  }

  Widget _buildListView() {
    return Selector<OrderModel, List<OrderEntity>>(
      selector: (_, model) => model.orders,
      builder: (c, orders, w) {
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            OrderEntity order = orders[index];
            return _buildItemView(order);
          },
        );
      },
    );
  }

  Widget _buildItemView(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(order.productUid ?? ''),
        const SizedBox(height: 4),
        Text('${order.status}'),
        const SizedBox(height: 4),
        Text(order.trackingNumber ?? ''),
      ]),
    );
  }
}
