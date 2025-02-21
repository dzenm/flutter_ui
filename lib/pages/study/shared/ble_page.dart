import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/pages/study/study_model.dart';
import 'package:provider/provider.dart';

import '../../shared/ble.dart';

///
/// Created by a0010 on 2025/1/25 11:57
///
class BlePage extends StatefulWidget {
  const BlePage({super.key});

  @override
  State<BlePage> createState() => _BlePageState();
}

class _BlePageState extends State<BlePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    return Scaffold(
      appBar: const CommonBar(
        title: '蓝牙传输',
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ListView(children: [
          TapLayout(
            background: theme.button,
            borderRadius: BorderRadius.circular(4),
            height: 40,
            onTap: () {
              BleManager().start();
            },
            child: const Text('开始扫描'),
          ),
          const SizedBox(height: 16),
          TapLayout(
            background: theme.button,
            borderRadius: BorderRadius.circular(4),
            height: 40,
            onTap: () {
              BleManager().stop();
            },
            child: const Text('停止扫描'),
          ),
          const SizedBox(height: 16),
          ..._buildBleList(),
        ]),
      ),
    );
  }

  List<Widget> _buildBleList() {
    List<BleEntity> list = context.watch<StudyModel>().devices;
    List<Widget> children = [];
    for (var item in list) {
      children.add(TapLayout(
        height: 40,
        child: Text(item.name),
      ));
    }
    return children;
  }
}
