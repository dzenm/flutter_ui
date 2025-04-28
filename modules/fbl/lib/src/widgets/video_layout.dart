import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

const _kTestUrl = 'https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4';

///
/// Created by a0010 on 2024/5/21 10:53
/// 视频播放组件
class VideoLayout extends StatefulWidget {
  final String url;

  const VideoLayout({super.key, String? url}) : url = url ?? _kTestUrl;

  @override
  State<VideoLayout> createState() => _VideoLayoutState();
}

class _VideoLayoutState extends State<VideoLayout> {
  late final player = Player();

  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    // Play a [Media] or [Playlist].
    player.open(Media(widget.url));
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width * 9.0 / 16.0,
        // Use [Video] widget to display video output.
        child: Video(
          controller: controller,
          wakelock: true,
          fill: Colors.white,
          filterQuality: FilterQuality.high,
          pauseUponEnteringBackgroundMode: true,
          resumeUponEnteringForegroundMode: true,
        ),
      ),
    );
  }
}
