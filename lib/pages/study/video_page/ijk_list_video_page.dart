import 'package:flutter/material.dart';

import 'ijk_video_page.dart';

class IjkListVideoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _IjkListVideoPageState();
}

class _IjkListVideoPageState extends State<IjkListVideoPage> {
  List<String> _list = [
    'asset:///assets/video/butterfly.mp4',
    'asset:///assets/video/butterfly.mp4',
    'asset:///assets/video/butterfly.mp4',
    'asset:///assets/video/butterfly.mp4',
    'asset:///assets/video/butterfly.mp4',
    'asset:///assets/video/butterfly.mp4',
  ];

  List<String> _thumbList = [
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
        child: AppBar(
          leading: null,
          backgroundColor: Colors.transparent,
          brightness: Brightness.dark,
        ),
        preferredSize: Size.fromHeight(0),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: _list.length,
          itemBuilder: (context, index) {
            return VideoPlayerView(url: _list[index], thumbUrl: _thumbList[index]);
          },
        ),
      ),
    );
  }
}
