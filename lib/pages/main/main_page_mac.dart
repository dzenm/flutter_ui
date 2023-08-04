import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/6/29 15:49
///
class MainPageMac extends StatefulWidget {
  const MainPageMac({super.key});

  @override
  State<StatefulWidget> createState() => _MainPageMacState();
}

class _MainPageMacState extends State<MainPageMac> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: const Text('测试数据'),
      ),
    );
  }
}
