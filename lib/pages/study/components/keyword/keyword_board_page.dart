import 'package:flutter/material.dart';

import '../../../../base/base.dart';


/// 自定义键盘
class KeywordBoardPage extends StatefulWidget {
  const KeywordBoardPage({super.key});

  @override
  State<StatefulWidget> createState() => _KeywordBoardPageState();
}

class _KeywordBoardPageState extends State<KeywordBoardPage> {
  final List<String> _license = ['', '', '', '', '', '', ''];
  final LicenseController _controller = LicenseController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频播放', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            LicenseView(list: _license, controller: _controller),
          ],
        ),
      ),
    );
  }
}
