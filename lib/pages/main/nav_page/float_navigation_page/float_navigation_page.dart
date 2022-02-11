import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/widgets/float_navigation_bar.dart';

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
        elevation: 0.0,
        title: Text('NavigationBar', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(child: Text('hello')),
      bottomNavigationBar: FloatNavigationBar(_navs, title: _title),
    );
  }
}
