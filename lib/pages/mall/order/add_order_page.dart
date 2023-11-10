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
      EditLayout(
        title: const Text(
          '联系人\u3000',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        hintText: '收件人姓名',
        color: const Color(0xFFE0E0E0),
        enabledBorderColor: Colors.transparent,
        controller: _usernameController,
        maxLength: 20,
      ),
      const SizedBox(height: 8),
      EditLayout(
        title: const Text(
          '收货地址',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        hintText: '收件人详细地址',
        color: const Color(0xFFE0E0E0),
        enabledBorderColor: Colors.transparent,
        maxLines: 3,
        keyboardType: TextInputType.multiline,
        controller: _addressController,
        maxLength: 30,
      ),
      const SizedBox(height: 8),
      EditLayout(
        title: const Text(
          '手机号码',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        hintText: '收件人联系方式',
        color: const Color(0xFFE0E0E0),
        enabledBorderColor: Colors.transparent,
        keyboardType: TextInputType.number,
        controller: _phoneController,
        maxLength: 11,
      ),
      const SizedBox(height: 8),
      EditLayout(
        title: const Text(
          '快递单号',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        hintText: '快递单号',
        color: const Color(0xFFE0E0E0),
        enabledBorderColor: Colors.transparent,
        keyboardType: TextInputType.text,
        controller: _trackingNumberController,
        maxLength: 25,
      ),
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
    order.orderUid = StrUtil.generateUUidString();
    order.receiver = _usernameController.text;
    order.receiveAddress = _addressController.text;
    order.receivePhone = _phoneController.text;
    ProductEntity product = ProductEntity();
    product.trackingNumber = _trackingNumberController.text;
    order.products.add(product);

    context.read<OrderModel>().updateOrder(order);
    AppRouteDelegate.of(context).pop();
  }
}
