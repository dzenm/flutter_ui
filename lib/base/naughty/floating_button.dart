import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class FloatingButton extends StatefulWidget {
  final ImageProvider imageProvider;
  final GestureTapCallback? onTap;

  const FloatingButton({
    super.key,
    required this.imageProvider,
    this.onTap,
  });

  @override
  State<StatefulWidget> createState() => _FloatingButtonState();
}

class _FloatingButtonState extends State<FloatingButton> with TickerProviderStateMixin {
  double _left = 0.0; //按钮在屏幕上的x坐标
  double _top = 100.0; //按钮在屏幕上的y坐标
  final double _radius = 50.0;

  bool isLeft = true; //按钮是否在按钮左侧
  bool isEdge = true; //按钮是否处于边缘
  bool isMove = false; //按钮是否被移动

  AnimationController? _controller;
  Animation? _animation; // 松开后按钮返回屏幕边缘的动画

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _left,
      top: _top,
      child: Listener(
        //按下后设isPress为true，绘制选中阴影
        onPointerMove: (details) {
          // setState(() => isMove = true);
        },
        //按下后设isPress为false，不绘制阴影
        //放下后根据当前x坐标与1/2屏幕宽度比较，判断屏幕在屏幕左侧或右侧，设置返回边缘动画
        //动画结束后设置isLeft的值，根据值绘制左/右边缘按钮
        onPointerUp: (e) async {
          if (isMove) {
            var pixelDetails = MediaQuery.of(context).size; //获取屏幕信息

            bool isPositionInLeft = e.position.dx <= pixelDetails.width / 2;
            _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100)); //0.1s动画
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

class FloatingButtonPainter extends CustomPainter {
  //按钮是否在屏幕左侧，屏幕宽度 / 2
  final bool isLeft;

  //按钮是否在屏幕边界，左/右边界
  final bool isEdge;

  //按钮是否被按下
  final bool isPress;

  //内按钮图片 ui.image
  final ui.Image buttonImage;

  // 高度
  double _height = 0;

  // 半径
  double _radius = 0;

  // 半圆相对贴边的矩形的偏移量
  double _offset = 0;

  FloatingButtonPainter({
    Key? key,
    required this.isLeft,
    required this.isEdge,
    required this.isPress,
    required this.buttonImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _height = size.width;
    _radius = min<double>(size.width, size.height) / 2;
    _offset = _radius;
    if (isEdge) {
      paintEdgeButton(canvas, size, isLeft); //绘制左右两边缘按钮
    } else {
      paintCenterButton(canvas, size); //绘制中心按钮
    }
  }

  //绘制吸附左右边界按钮
  void paintEdgeButton(Canvas canvas, Size size, bool isLeft) {
    //绘制按钮内层
    Paint paint = Paint()
      ..isAntiAlias = false
      ..style = PaintingStyle.fill
      ..color = const Color.fromRGBO(0xF3, 0xF3, 0xF3, 0.9);

    // path : 按钮矩形的范围（不包括半圆）
    Path path;
    if (isLeft) {
      path = Path()
        ..moveTo(_offset, _height)
        ..lineTo(0.0, _height)
        ..lineTo(0.0, 0.0)
        ..lineTo(_offset, 0.0);
    } else {
      path = Path()
        ..moveTo(_offset, 0.0)
        ..lineTo(_height, 0.0)
        ..lineTo(_height, _height)
        ..lineTo(_offset, _height);
    }

    // edgePath: 按钮外边缘灰色路径边框
    Path edgePath;
    if (isLeft) {
      Rect rect = Rect.fromCircle(center: Offset(_offset, _radius), radius: _radius);
      path.arcTo(rect, pi * 1.5, pi, true);
      canvas.drawPath(path, paint);

      edgePath = Path.from(path)..arcTo(Rect.fromCircle(center: Offset(_offset, _radius), radius: _radius), pi * 1.5, pi, true);
    } else {
      Rect rect = Rect.fromCircle(center: Offset(_offset, _radius), radius: _radius);
      path.arcTo(rect, pi * 0.5, pi, true);
      canvas.drawPath(path, paint);

      edgePath = Path.from(path)..arcTo(Rect.fromCircle(center: Offset(_offset, _radius), radius: _radius), pi * 0.5, pi, true);
    }

    paint
      ..isAntiAlias = true
      ..strokeWidth = 0.75
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.25) //线条模糊
      ..style = PaintingStyle.stroke
      ..color = const Color.fromRGBO(0xCF, 0xCF, 0xCF, 1);
    canvas.drawPath(edgePath, paint);

    //按下则画阴影，表示选中
    if (isPress) canvas.drawShadow(isLeft ? edgePath : path, const Color.fromRGBO(0xDA, 0xDA, 0xDA, 0.3), 0, false);

    _paintCircleImage(canvas);
  }

  //绘制不贴边时移动的按钮
  void paintCenterButton(Canvas canvas, Size size) {
    //绘制按钮内层
    var paint = Paint()
      ..isAntiAlias = false
      ..style = PaintingStyle.fill
      ..color = const Color.fromRGBO(0xF3, 0xF3, 0xF3, 0.9);
    canvas.drawCircle(Offset(_radius, _radius), _radius, paint);

    //绘制按钮外层边框
    paint
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.25)
      ..color = const Color.fromRGBO(0xCF, 0xCF, 0xCF, 1);
    canvas.drawCircle(Offset(_radius, _radius), _radius, paint);

    //如果按下则绘制阴影
    if (isPress) {
      var circlePath = Path()
        ..moveTo(_radius, _radius)
        ..arcTo(Rect.fromCircle(center: Offset(_radius, _radius), radius: _radius), 0, 2 * 3.14, true); //使用pi会出错。
      canvas.drawShadow(circlePath, const Color.fromRGBO(0xCF, 0xCF, 0xCF, 0.3), 0.5, false);
    }

    _paintCircleImage(canvas);
  }

  //绘制圆形的图片位置
  void _paintCircleImage(Canvas canvas) {
    //绘制中间图标
    Paint paint = Paint();
    canvas.save(); //图片剪裁前保存图层

    RRect imageRRect = RRect.fromRectAndRadius(Rect.fromLTWH(_radius - 17.5, _radius - 17.5, 35, 35), const Radius.circular(17.5));
    canvas.clipRRect(imageRRect); //图片为圆形，圆形剪裁
    canvas.drawColor(Colors.white, BlendMode.srcOver); //设置填充颜色为白色

    Rect srcRect = Rect.fromLTWH(0.0, 0.0, buttonImage.width.toDouble(), buttonImage.height.toDouble());
    Rect dstRect = Rect.fromLTWH(_radius - 17.5, _radius - 17.5, 35, 35);
    canvas.drawImageRect(buttonImage, srcRect, dstRect, paint);
    canvas.restore(); //图片绘制完毕恢复图层
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
