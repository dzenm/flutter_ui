import 'package:flutter/material.dart';

import '../../../base/base.dart';
import 'ijk_list_video_page.dart';
import 'ijk_video_page.dart';
import 'vlc_video_page.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<StatefulWidget> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('视频播放', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: _listWidgets()),
      ),
    );
  }

  List<Widget> _listWidgets() {
    return [
      const SizedBox(height: 8),
      MaterialButton(
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => AppRouter.of(context).pushPage(const VlcVideoPage()),
        child: _text('VLC播放器'),
      ),
      const SizedBox(height: 8),
      MaterialButton(
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => AppRouter.of(context).pushPage(const IjkVideoPage(url: Assets.butterfly)),
        child: _text('IJK视频播放'),
      ),
      const SizedBox(height: 8),
      MaterialButton(
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => AppRouter.of(context).pushPage(const IjkListVideoPage()),
        child: _text('原生视频播放'),
      ),
      const SizedBox(height: 16),
      LicenseView(
        list: const ['京', 'A', '9', '7', '8', 'H', '', ''],
        controller: _controller,
      ),
      MaterialButton(
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => setState(() => _controller.setSelect(_controller.select + 1)),
        child: _text('其他视频播放'),
      ),
    ];
  }

  final LicenseController _controller = LicenseController();

  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
