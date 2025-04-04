import 'dart:io';

import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';

import '../../../widgets/widgets.dart';

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
    Directory cacheDir = LocalStorage().getUserDirectory('test');
    Directory imageDir = LocalStorage().getUserDirectory('image');
    Log.d('获取当前APP根目录：cacheDir=${cacheDir.path}');
    Log.d('获取当前APP根目录：imageDir=${imageDir.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonBar(
        elevation: 0.0,
        title: '导航栏',
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: const VideoLayout(),
      ),
      bottomNavigationBar: FloatNavigationBar(_nav, title: _title),
    );
  }
}
