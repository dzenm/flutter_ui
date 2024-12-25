import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/entities/entity.dart';
import 'package:flutter_ui/generated/l10n.dart';
import 'package:flutter_ui/pages/common/city_select.dart';
import 'package:flutter_ui/pages/routers.dart';
import 'package:provider/provider.dart';

import 'order_model.dart';

///
/// Created by a0010 on 2024/12/25 14:45
///
class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  late TextEditingController _usernameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _trackingNumberController;
  final List<OrderEntity> _products = [];
  bool _isDisableButton = true;

  @override
  void initState() {
    super.initState();
    _initInputText();
  }

  void _initInputText() {
    _usernameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _trackingNumberController = TextEditingController();

    _usernameController.addListener(() {
      _resetButtonState();
    });
    _addressController.addListener(() {
      _resetButtonState();
    });
    _phoneController.addListener(() {
      _resetButtonState();
    });
    _trackingNumberController.addListener(() {
      _resetButtonState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonBar(title: '创建收获地址'),
      body: _buildInputView(),
    );
  }

  Widget _buildInputView() {
    AppTheme theme = context.watch<LocalModel>().theme;
    return ListView(padding: const EdgeInsets.all(16), children: [
      EditLayout(
        title: Text(
          '${S.of(context).contact}\u3000',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        hintText: S.of(context).recipientName,
        color: const Color(0xFFE0E0E0),
        enabledBorderColor: Colors.transparent,
        controller: _usernameController,
        maxLength: 20,
      ),
      const SizedBox(height: 8),
      EditLayout(
        title: Text(
          S.of(context).shippingAddress,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        hintText: S.of(context).recipientsDetailedAddress,
        color: const Color(0xFFE0E0E0),
        enabledBorderColor: Colors.transparent,
        maxLines: 3,
        keyboardType: TextInputType.multiline,
        controller: _addressController,
        maxLength: 30,
      ),
      const SizedBox(height: 8),
      EditLayout(
        title: Text(
          S.of(context).phone,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        hintText: S.of(context).recipientContactInfo,
        color: const Color(0xFFE0E0E0),
        enabledBorderColor: Colors.transparent,
        keyboardType: TextInputType.number,
        controller: _phoneController,
        maxLength: 11,
      ),
      const SizedBox(height: 8),
      EditLayout(
        title: Text(
          S.of(context).trackingNumber,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        hintText: S.of(context).trackingNumber,
        color: const Color(0xFFE0E0E0),
        enabledBorderColor: Colors.transparent,
        keyboardType: TextInputType.text,
        controller: _trackingNumberController,
        maxLength: 25,
      ),
      const SizedBox(height: 8),
      TapLayout(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        background: theme.appbar,
        onTap: () async {
          CityModel? result = await context.pushNamed(Routers.citySelected);
          setState(() => _city = result?.name ?? '');
        },
        child: Text(
          _city,
          style: TextStyle(color: theme.white),
        ),
      ),
      const SizedBox(height: 8),
      // Expanded(child: _buildProducts()),
      // const SizedBox(height: 8),
      TapLayout(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        background: _isDisableButton ? theme.unchecked : theme.checked,
        onTap: _isDisableButton ? null : _createOrder,
        child: Text(
          S.of(context).save,
          style: TextStyle(color: theme.white),
        ),
      ),
      ..._buildProducts(),
    ]);
  }

  String _city = '选择城市';

  void _resetButtonState() {
    bool isDisable = _usernameController.text.isEmpty || //
        _addressController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _trackingNumberController.text.isEmpty;
    setState(() => _isDisableButton = isDisable);
  }

  List<Widget> _buildProducts() {
    return _products.map((product) {
      return Container();
    }).toList();
  }

  void _createOrder() {
    String orderUid = StrUtil.generateUUidString();
    String receiveAddress = _addressController.text;
    String receivePhone = _phoneController.text;
    OrderEntity order = OrderEntity();
    order.orderUid = orderUid;

    String productUid1 = StrUtil.generateUUidString();
    OrderEntity product = OrderEntity();
    product.orderUid = orderUid;
    product.productUid = productUid1;
    product.trackingNumber = _trackingNumberController.text;


    context.read<OrderModel>().updateOrder(order);
    context.pop();
  }
}
