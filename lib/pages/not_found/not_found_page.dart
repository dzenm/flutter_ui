import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NotFoundPage extends StatefulWidget {
  @override
  _NotFoundPageState createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.red,
        elevation: 0.0,
        title: Text('Page is not found'),
      ),
      body: Center(child: Text('Page is not found, please check it')),
    );
  }
}
