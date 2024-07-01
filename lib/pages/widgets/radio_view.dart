import 'package:flutter/material.dart';

///
/// Created by laijiahui on 2023/05/11 14:13
/// 选择按钮组件
class RadioView extends StatelessWidget {
  final bool isSelect;

  const RadioView({super.key, this.isSelect = false});

  @override
  Widget build(BuildContext context) {
    IconData icon = isSelect ? Icons.radio_button_checked : Icons.radio_button_unchecked;
    Color color = isSelect ? Colors.blue : Colors.grey;
    return Icon(icon, color: color, size: 20);
  }
}
