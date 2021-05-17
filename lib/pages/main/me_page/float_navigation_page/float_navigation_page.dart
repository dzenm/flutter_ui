import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/widgets/float_navigation_bar.dart';

class FloatNavigationPage extends StatefulWidget {
  @override
  _FloatNavigationPageState createState() => _FloatNavigationPageState();
}

class _FloatNavigationPageState extends State<FloatNavigationPage> {

  List<IconData> _navs = [
    Icons.search,
    Icons.ondemand_video,
    Icons.music_video,
    Icons.insert_comment,
    Icons.person,
  ]; // 导航项

  List<String> _title = [
    '搜索',
    '视频',
    '音乐',
    '评论',
    '我的',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Text('NavigationBar'),
        centerTitle: true,
      ),
      backgroundColor: Color(0xFFFF0035),
      body: Center(child: Text('hello')),
      bottomNavigationBar: FloatNavigationBar(_navs, title: _title,),
    );
  }
}
