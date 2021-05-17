import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

//子页面
//代码中设置了一个内部的_title变量，这个变量是从主页面传递过来的，然后根据传递过来的具体值显示在APP的标题栏和屏幕中间。
class HomePage extends StatefulWidget {
  final String _title;

  HomePage(this._title);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _controller = new TextEditingController(text: "初始化");
  String text = '';

  @override
  void initState() {
    super.initState();
    text = _controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget._title)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text('Home Page'),
        ),
      ),
    );
  }
}
