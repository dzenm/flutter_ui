import 'package:flutter/material.dart';
import 'package:flutter_ui/base/res/lang/strings.dart';
import 'package:flutter_ui/base/widgets/license_view.dart';

/// 自定义键盘
class KeywordBoardPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _KeywordBoardPageState();
}

class _KeywordBoardPageState extends State<KeywordBoardPage> {
  List<String> _license = ['', '', '', '', '', '', ''];
  LicenseController _controller = LicenseController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).videoPlay, style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            LicenseView(list: _license, controller: _controller),
          ],
        ),
      ),
    );
  }
}
