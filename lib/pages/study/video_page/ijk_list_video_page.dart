import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ijk_video_page.dart';

class IjkListVideoPage extends StatefulWidget {
  const IjkListVideoPage({super.key});

  @override
  State<StatefulWidget> createState() => _IjkListVideoPageState();
}

class _IjkListVideoPageState extends State<IjkListVideoPage> {
  final List<String> _list = [
    'asset:///assets/video/butterfly.mp4',
    'asset:///assets/video/butterfly.mp4',
    'asset:///assets/video/butterfly.mp4',
    'asset:///assets/video/butterfly.mp4',
    'asset:///assets/video/butterfly.mp4',
    'asset:///assets/video/butterfly.mp4',
  ];

  final List<String> _thumbList = [
    'assets/image/thumb_video_cover.png',
    'assets/image/thumb_video_cover.png',
    'assets/image/thumb_video_cover.png',
    'assets/image/thumb_video_cover.png',
    'assets/image/thumb_video_cover.png',
    'assets/image/thumb_video_cover.png',
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          leading: null,
          backgroundColor: Colors.transparent,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _list.length,
        itemBuilder: (context, index) {
          return VideoPlayerView(url: _list[index], thumbUrl: _thumbList[index]);
        },
      ),
    );
  }
}
