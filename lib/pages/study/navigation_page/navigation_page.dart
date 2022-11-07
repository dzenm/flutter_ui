import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/res/strings.dart';

// 导航
class NavigationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).navigation, style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Stack(),
      ),
    );
  }
}

