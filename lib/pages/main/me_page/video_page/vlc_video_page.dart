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
    //   hwAcc: HwAcc.FULL,
    //   autoPlay: true,
    //   options: VlcPlayerOptions(),
    // );
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
        title: Text(S.of.vlcVideoPlay, style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        alignment: Alignment.center,
        // child: VlcPlayer(
        //   controller: _controller!,
        //   aspectRatio: 16 / 9,
        //   placeholder: Center(
        //     child: Stack(
        //       children: [
        //         Image.asset(Assets.image('a.png')),
        //         CircularProgressIndicator(),
        //       ],
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
