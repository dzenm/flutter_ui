import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/res/strings.dart';

class VlcVideoPage extends StatefulWidget {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).vlcVideoPlay, style: TextStyle(color: Colors.white)),
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
