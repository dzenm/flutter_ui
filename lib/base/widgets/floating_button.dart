import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_ui/base/widgets/floating_button_painter.dart';

class FloatingButton extends StatefulWidget {
  final ImageProvider imageProvider;
  final GestureTapCallback? onTap;

  FloatingButton({
    required this.imageProvider,
    this.onTap,
  });

  @override
  _FloatingButtonState createState() => _FloatingButtonState();
}

class _FloatingButtonState extends State<FloatingButton> with TickerProviderStateMixin {
  double _left = 0.0; //按钮在屏幕上的x坐标
  double _top = 100.0; //按钮在屏幕上的y坐标
  double _radius = 50.0;

  bool isLeft = true; //按钮是否在按钮左侧
  bool isEdge = true; //按钮是否处于边缘
  bool isPress = false; //按钮是否被按下
  bool isMove = false; //按钮是否被按下

  AnimationController? _controller;
  Animation? _animation; // 松开后按钮返回屏幕边缘的动画

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _left,
      top: _top,
      child: Listener(
        //按下后设isPress为true，绘制选中阴影
        onPointerDown: (details) => setState(() => isPress = true),
        onPointerMove: (details) => setState(() => isMove = true),
        //按下后设isPress为false，不绘制阴影
        //放下后根据当前x坐标与1/2屏幕宽度比较，判断屏幕在屏幕左侧或右侧，设置返回边缘动画
        //动画结束后设置isLeft的值，根据值绘制左/右边缘按钮
        onPointerUp: (e) async {
          setState(() => isPress = false);
          if (isMove) {
            var pixelDetails = MediaQuery.of(context).size; //获取屏幕信息

            bool isPositionInLeft = e.position.dx <= pixelDetails.width / 2;
            _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 100)); //0.1s动画
            _animation = Tween<double>(
              begin: e.position.dx,
              end: isPositionInLeft ? 0.0 : pixelDetails.width - _radius,
            ).animate(_controller!)
              ..addListener(() {
                setState(() => _left = _animation?.value); //更新x坐标
              });
            await _controller?.forward(); //等待动画结束
            _controller?.dispose(); //释放动画资源
            setState(() {
              isLeft = isPositionInLeft; //按钮在屏幕左侧
              isEdge = true; //按钮返回至边缘
              isMove = false;
            });
          }

        },
        child: GestureDetector(
          onTap: widget.onTap,
          //拖拽更新
          onPanUpdate: (details) {
            var pixelDetails = MediaQuery.of(context).size; //获取屏幕信息
            setState(() {
              //拖拽更新坐标
              _left += details.delta.dx;
              _top += details.delta.dy;
              //拖拽后更新按钮信息，是否处于边缘
              isEdge = !(_left > 0 && _left < pixelDetails.width - _radius);
            });
          },
          child: FutureBuilder<ui.Image>(
            future: loadImageByProvider(widget.imageProvider),
            builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) => CustomPaint(
              size: Size(_radius, _radius),
              painter: snapshot.data == null
                  ? null
                  : FloatingButtonPainter(
                      isLeft: isLeft,
                      isEdge: isEdge,
                      isPress: isMove,
                      buttonImage: snapshot.data!,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  //通过ImageProvider获取ui.image
  Future<ui.Image> loadImageByProvider(
    ImageProvider provider, {
    ImageConfiguration config = ImageConfiguration.empty,
  }) async {
    Completer<ui.Image> completer = Completer<ui.Image>(); //完成的回调
    ImageStreamListener? listener;
    ImageStream stream = provider.resolve(config); //获取图片流
    listener = ImageStreamListener((ImageInfo frame, bool sync) {
      //监听
      final ui.Image image = frame.image;
      completer.complete(image); //完成
      if (listener != null) {
        stream.removeListener(listener); //移除监听
      }
    });
    stream.addListener(listener); //添加监听
    return completer.future; //返回
  }
}
