import 'package:flutter/material.dart';
import 'package:flutter_ui/pages/mall/order/order_model.dart';
import 'package:provider/provider.dart';

import '../../../base/base.dart';
import '../../../entities/entity.dart';

/// 订单页面
class AddOrderPage extends StatefulWidget {
  const AddOrderPage({super.key});

  @override
  State<AddOrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<AddOrderPage> {
  late TextEditingController _usernameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _trackingNumberController;

  @override
  void initState() {
    super.initState();

    _usernameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _trackingNumberController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonBar(
        title: '创建订单',
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: _buildInputView(),
        ),
      ),
    );
  }

  Widget _buildInputView() {
    AppTheme theme = context.watch<LocalModel>().theme;
    return Column(children: [
      SingleEditLayout(title: '收货人       ', controller: _usernameController, maxLength: 25),
      const SizedBox(height: 8),
      SingleEditLayout(title: '收货地址     ', controller: _addressController, maxLength: 25),
      const SizedBox(height: 8),
      SingleEditLayout(title: '收货人手机号码', controller: _phoneController, maxLength: 25),
      const SizedBox(height: 8),
      SingleEditLayout(title: '快递单号     ', controller: _trackingNumberController, maxLength: 25),
      const SizedBox(height: 8),
      TapLayout(
        background: theme.appbar,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        onTap: _createOrder,
        child: Text(
          '保存',
          style: TextStyle(color: theme.white),
        ),
      ),
    ]);
  }

  void _createOrder() {
    OrderEntity order = OrderEntity();
    order.receiver = _usernameController.text;
    order.receiveAddress = _addressController.text;
    order.receivePhone = _phoneController.text;
    order.trackingNumber = _trackingNumberController.text;

    context.read<OrderModel>().updateOrder(order);
  }
}
