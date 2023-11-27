import 'package:flutter/material.dart';

import '../../../entities/entity.dart';

class OrderModel with ChangeNotifier {
  final Map<String, OrderEntity> _orders = {};

  Future<void> init() async {
    List<OrderEntity> list = await OrderEntity().query();
    for (var order in list) {
      _orders[order.orderUid!] = order;
    }
  }

  List<OrderEntity> get orders => _orders.values.toList();

  OrderEntity? getOrder(String? orderUid) {
    if (orderUid == null) return null;
    OrderEntity? order = _orders[orderUid];
    return order;
  }

  void updateOrder(OrderEntity order) {
    String orderUid = order.orderUid!;
    OrderEntity? oldOrder = _orders[orderUid];
    if (oldOrder == null) {
      _orders[orderUid] = order;
      OrderEntity().insert(order);
    } else {
      _orders[orderUid] = order;
      OrderEntity().update(order);
    }
  }

}
