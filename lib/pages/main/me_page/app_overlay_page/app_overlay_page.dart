import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/widgets/app_overlay.dart';

class AppOverlayPage extends StatefulWidget {
  @override
  _AppOverlayPageState createState() => _AppOverlayPageState();
}

class _AppOverlayPageState extends State<AppOverlayPage> {
  static OverlayEntry? entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('全局悬浮窗'),
        centerTitle: true,
      ),
      body: getBody(),
    );
  }

  Widget getBody() {
    return Column(
      children: <Widget>[
        RaisedButton(
          child: Text("add"),
          onPressed: () {
            entry?.remove();
            entry = null;
            entry = OverlayEntry(builder: (context) {
              return AppFloatBox();
            });
            Overlay.of(context)!.insert(entry!);
          },
        ),
        RaisedButton(
          child: Text("delete"),
          onPressed: () {
            entry?.remove();
            entry = null;
          },
        ),
      ],
    );
  }
}
