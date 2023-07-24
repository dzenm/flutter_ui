import 'package:flutter/material.dart';
import 'package:flutter_ui/base/widgets/float_navigation_bar.dart';

/// 浮动的导航栏和PopupWindow
class FloatNavigationPage extends StatefulWidget {
  const FloatNavigationPage({super.key});

  @override
  State<StatefulWidget> createState() => _FloatNavigationPageState();
}

class _FloatNavigationPageState extends State<FloatNavigationPage> {
  final List<IconData> _nav = [
    Icons.search,
    Icons.ondemand_video,
    Icons.music_video,
    Icons.insert_comment,
    Icons.person,
  ]; // 导航项

  final List<String> _title = ['搜索', '视频', '音乐', '评论', '我的'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text('导航栏', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      bottomNavigationBar: FloatNavigationBar(_nav, title: _title),
    );
  }
}
