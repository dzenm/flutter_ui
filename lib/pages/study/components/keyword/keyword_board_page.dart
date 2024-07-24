import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';

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
      appBar: const CommonBar(
        title: '视频播放',
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
