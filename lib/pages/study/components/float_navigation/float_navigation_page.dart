import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../base/base.dart';

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
  void initState() {
    super.initState();

    _getData();
  }

  void _getData() async {
    Directory cacheDir = FileUtil().getUserDirectory('test');
    Directory imageDir = FileUtil().getUserDirectory('image');
    Log.d('获取当前APP根目录：cacheDir=${cacheDir.path}');
    Log.d('获取当前APP根目录：imageDir=${imageDir.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text('导航栏', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: const VideoLayout(),
      ),
      bottomNavigationBar: FloatNavigationBar(_nav, title: _title),
    );
  }
}
