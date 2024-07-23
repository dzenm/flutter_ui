import 'package:flutter/material.dart';
import 'package:flutter_ui/base/base.dart';

class VlcVideoPage extends StatefulWidget {
  const VlcVideoPage({super.key});

  @override
  State<StatefulWidget> createState() => _VlcVideoPageState();
}

class _VlcVideoPageState extends State<VlcVideoPage> {
  // VlcPlayerController? _controller;

  @override
  void initState() {
    super.initState();

    // _controller = VlcPlayerController.network(
    //   'https://media.w3.org/2010/05/sintel/trailer.mp4',
    //   hwAcc: HwAcc.full,
    //   autoPlay: true,
    //   options: VlcPlayerOptions(),
    // );
    // _controller = VlcPlayerController.asset(
    //   Assets.video('butterfly.mp4'),
    //   hwAcc: HwAcc.full,
    //   autoPlay: false,
    //   options: VlcPlayerOptions(),
    // );
    // _controller?.addListener(() {
    //   Log.d('视频播放状态: ${_controller?.value.playingState}');
    // });
  }

  @override
  void dispose() async {
    super.dispose();
    // await _controller?.stopRendererScanning();
    // await _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CommonBar(
        title: 'VLC视频播放',
      ),
      // body: Container(
      //   alignment: Alignment.center,
      //   child: VlcPlayer(
      //     controller: _controller!,
      //     aspectRatio: 16 / 9,
      //     placeholder: Center(
      //       child: Stack(
      //         children: [
      //           Image.asset(Assets.image('a.jpg')),
      //           CircularProgressIndicator(),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
//
// class PlayVideoPage extends StatefulWidget {
//   final String url;
//
//   PlayVideoPage({required this.url});
//
//   @override
//   State<StatefulWidget> createState() => _PlayVideoPageState();
// }
//
// class _PlayVideoPageState extends State<PlayVideoPage> {
//   VlcPlayerController? _controller;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = createPlayController(url: widget.url);
//     _controller?.addListener(() {
//       Log.d('视频播放器监听状态: playingState=${_controller?.value.playingState}');
//     });
//   }
//
//   @override
//   void dispose() async {
//     await _controller?.stopRendererScanning();
//     await _controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         color: Colors.black,
//         child: Center(
//           child: createPlayVideoView(controller: _controller),
//         ),
//       ),
//     );
//   }
// }
//
// VlcPlayerController createPlayController({required String url}) {
//   Log.d('播放的视频路径：url=$url');
//   if (url.startsWith('http')) {
//     return VlcPlayerController.network(
//       url,
//       hwAcc: HwAcc.full,
//       autoPlay: true,
//       options: VlcPlayerOptions(),
//     );
//   } else {
//     File file = File(url);
//     if (!file.existsSync()) {
//       file = File(Uri.file(url).path);
//     }
//     Log.d('播放视频的文件是否存在：exists=${file.existsSync()}');
//     return VlcPlayerController.file(
//       file,
//       hwAcc: HwAcc.full,
//       autoPlay: true,
//       options: VlcPlayerOptions(),
//     );
//   }
// }
//
// // 视频播放布局
// Widget createPlayVideoView({VlcPlayerController? controller, String? thumbPath}) {
//   if (controller == null) return Container();
//   Log.d('播放视频：controller=$controller');
//   bool _init = false;
//   controller.addListener(() {
//     Log.d('播放视频：addListener=$controller');
//     // 第一次打开时，缓冲视频，获取到视频信息
//     if (!_init && controller.value.duration.inSeconds > 0) {
//       _init = true;
//     }
//   });
//   controller.addOnInitListener(() {
//     Log.d('播放视频：addOnInitListener=$controller');
//   });
//   controller.addOnRendererEventListener((p0, p1, p2) {
//     Log.d('播放视频：addOnRendererEventListener=$controller');
//   });
//   return VlcPlayer(
//     controller: controller,
//     aspectRatio: controller.value.aspectRatio,
//     placeholder: Stack(
//       children: [
//         CircularProgressIndicator(color: Colors.white),
//       ],
//     ),
//   );
// }
