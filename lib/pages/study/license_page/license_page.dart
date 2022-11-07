import 'package:flutter/material.dart';
import 'package:flutter_ui/base/res/strings.dart';

class LicensePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LicensePageState();
}

class _LicensePageState extends State<LicensePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).videoPlay, style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Stack(

        ),
      ),
    );
  }
}
