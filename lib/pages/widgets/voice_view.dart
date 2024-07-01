import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/10/31 16:15
///
class VoiceAnimationImage extends StatefulWidget {
  final List<String>? assetList;
  final bool rotate;
  final double size;
  final Color color;
  final bool play;

  const VoiceAnimationImage({
    super.key,
    this.assetList,
    this.rotate = false,
    this.size = 22,
    this.color = Colors.transparent,
    this.play = false,
  });

  @override
  State<StatefulWidget> createState() => VoiceAnimationImageState();
}

class VoiceAnimationImageState extends State<VoiceAnimationImage> with SingleTickerProviderStateMixin {
  // 动画控制
  late Animation<double> _animation;
  late AnimationController _controller;

  late List<String> assetList;

  @override
  void initState() {
    super.initState();

    var assets = widget.assetList;
    // assets ??= [Assets.recordAnim1, Assets.recordAnim2, Assets.recordAnim3];
    assets ??= [];
    assetList = assets;

    final int imageCount = assets.length;
    final int maxTime = 300 * imageCount;

    // 启动动画controller
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: maxTime));
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _controller.forward(from: 0.0); // 完成后重新开始
      }
    });

    _animation = Tween<double>(begin: 0, end: imageCount.toDouble()).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.play) {
      _controller.forward();
    } else {
      _controller.reset();
      _controller.stop();
    }
//    if(widget.isStop){
//      start();
//    }else{
//      stop();
//    }
//    int ix = _animation.value.floor() % widget._assetList.length;
//    List<Widget> images = [];
//    // 把所有图片都加载进内容，否则每一帧加载时会卡顿
//    for (int i = 0; i < widget._assetList.length; ++i) {
//      if (i != ix) {
//        images.add(Image.asset(
//          widget._assetList[i],
//          width: 0,
//          height: 0,
//          color: ColorConst.secondaryText,
//        ));
//      }
//    }
//    images.add(Image.asset(
//      widget._assetList[ix],
//      width: 22,
//      height: 22,
//      color: ColorConst.secondaryText,
//    ));
    return RotatedBox(
      quarterTurns: widget.rotate ? 2 : 0,
      child: Image.asset(
        assetList[assetList.length - 1 - _animation.value.floor()],
        width: widget.size,
        height: widget.size,
        color: widget.color,
      ),
    );
//    return  Stack(alignment: AlignmentDirectional.center, children: images);
  }
}
