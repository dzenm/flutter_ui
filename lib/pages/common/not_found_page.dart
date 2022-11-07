import 'package:flutter/material.dart';
import 'package:flutter_ui/base/res/strings.dart';

class NotFoundPage extends StatefulWidget {
  @override
  _NotFoundPageState createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).pageIsNotFound, style: TextStyle(color: Colors.white)),
      ),
      body: Center(child: Text(S.of(context).pageIsNotFoundPleaseCheckIt)),
    );
  }
}
