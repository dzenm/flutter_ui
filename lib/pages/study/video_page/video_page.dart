import 'package:flutter/material.dart';
import 'package:flutter_ui/base/res/assets.dart';
import 'package:flutter_ui/base/utils/route_manager.dart';
import 'package:flutter_ui/base/widgets/license_view.dart';

import 'ijk_list_video_page.dart';
import 'ijk_video_page.dart';
import 'vlc_video_page.dart';

class VideoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('视频播放', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(children: _listWidgets()),
      ),
    );
  }

  List<Widget> _listWidgets() {
    return [
      SizedBox(height: 8),
      MaterialButton(
        child: _text('VLC播放器'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(context, VlcVideoPage()),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text('IJK视频播放'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(context, IjkVideoPage(url: 'asset:///' + Assets.video('butterfly.mp4'))),
      ),
      SizedBox(height: 8),
      MaterialButton(
        child: _text('原生视频播放'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => RouteManager.push(context, IjkListVideoPage()),
      ),
      SizedBox(height: 16),
      LicenseView(
        list: ['京', 'A', '9', '7', '8', 'H', '', ''],
        controller: _controller,
      ),
      MaterialButton(
        child: _text('其他视频播放'),
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => setState(() => _controller.setSelect(_controller.select + 1)),
      ),
    ];
  }

  LicenseController _controller = LicenseController();

  Widget _text(String text) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text)]);
  }
}
