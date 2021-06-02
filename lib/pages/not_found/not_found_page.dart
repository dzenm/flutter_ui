import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/widgets/common_widget.dart';

class NotFoundPage extends StatefulWidget {
  @override
  _NotFoundPageState createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page is not found', style: TextStyle(color: Colors.white)),
        leading: leadingView(),
        elevation: 0.0,
      ),
      body: Center(child: Text('Page is not found, please check it')),
    );
  }
}
