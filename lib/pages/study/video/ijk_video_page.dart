import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoPlayerView extends StatefulWidget {
  final String url;
  final String thumbUrl;
  final bool autoPlay;

  const VideoPlayerView({
    super.key,
    required this.url,
    this.thumbUrl = '',
    this.autoPlay = false,
  });

  @override
  State<StatefulWidget> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  // FijkPlayer _player = FijkPlayer();

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    // await _player.setDataSource(widget.url, autoPlay: widget.autoPlay);
    // await _player.prepareAsync();
    // _player.addListener(() {
    //   Log.d('VideoPlay Current Status: ${_player.state}');
    //   if (!_videoInit && _player.value.prepared) {
    //     setState(() => _videoInit = true);
    //   }
    // });
  }

  @override
  void dispose() {
    super.dispose();
    // _player.release();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      // child: _videoInit
      //     ? AspectRatio(
      //         aspectRatio: _player.value.size!.aspectRatio,
      //         child: FijkView(
      //           player: _player,
      //           color: Colors.black,
      //           cover: _imageProvider(),
      //           // panelBuilder: fijkPanel2Builder(snapShot: true),
      //         ),
      //       )
      //     : Container(
      //         width: double.infinity,
      //         child: TapLayout(
      //           onTap: () => _player.start(),
      //           child: Image(image: _imageProvider(), fit: BoxFit.fitWidth),
      //         ),
      //       ),
    );
  }

// ImageProvider _imageProvider() {
//   String thumbUrl = widget.thumbUrl;
//   if (thumbUrl.startsWith('http://') || thumbUrl.startsWith('https://')) {
//     return NetworkImage(thumbUrl);
//   } else if (thumbUrl.startsWith('assets/')) {
//     return AssetImage(thumbUrl);
//   } else {
//     return FileImage(File(thumbUrl));
//   }
// }
}

class IjkVideoPage extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool repeat;

  const IjkVideoPage({
    super.key,
    required this.url,
    this.autoPlay = false,
    this.repeat = false,
  });

  @override
  State<StatefulWidget> createState() => _IjkVideoPageState();
}

class _IjkVideoPageState extends State<IjkVideoPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(0),
          child: CommonBar(
            leading: null,
            backgroundColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarBrightness: Brightness.dark,
            ),
          )),
      body: VideoPlayerView(
        url: 'asset:///assets/video/butterfly.mp4',
        thumbUrl: 'assets/image/thumb_video_cover.png',
      ),
    );
  }
}
