import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

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
      ..color = Color.fromRGBO(0xF3, 0xF3, 0xF3, 0.9);

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
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.25) //线条模糊
      ..style = PaintingStyle.stroke
      ..color = Color.fromRGBO(0xCF, 0xCF, 0xCF, 1);
    canvas.drawPath(edgePath, paint);

    //按下则画阴影，表示选中
    if (isPress) canvas.drawShadow(isLeft ? edgePath : path, Color.fromRGBO(0xDA, 0xDA, 0xDA, 0.3), 0, false);

    _paintCircleImage(canvas);
  }

  //绘制不贴边时移动的按钮
  void paintCenterButton(Canvas canvas, Size size) {
    //绘制按钮内层
    var paint = Paint()
      ..isAntiAlias = false
      ..style = PaintingStyle.fill
      ..color = Color.fromRGBO(0xF3, 0xF3, 0xF3, 0.9);
    canvas.drawCircle(Offset(_radius, _radius), _radius, paint);

    //绘制按钮外层边框
    paint
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 0.25)
      ..color = Color.fromRGBO(0xCF, 0xCF, 0xCF, 1);
    canvas.drawCircle(Offset(_radius, _radius), _radius, paint);

    //如果按下则绘制阴影
    if (isPress) {
      var circlePath = Path()
        ..moveTo(_radius, _radius)
        ..arcTo(Rect.fromCircle(center: Offset(_radius, _radius), radius: _radius), 0, 2 * 3.14, true); //使用pi会出错。
      canvas.drawShadow(circlePath, Color.fromRGBO(0xCF, 0xCF, 0xCF, 0.3), 0.5, false);
    }

    _paintCircleImage(canvas);
  }

  //绘制圆形的图片位置
  void _paintCircleImage(Canvas canvas) {
    //绘制中间图标
    Paint paint = Paint();
    canvas.save(); //图片剪裁前保存图层

    RRect imageRRect = RRect.fromRectAndRadius(Rect.fromLTWH(_radius - 17.5, _radius - 17.5, 35, 35), Radius.circular(17.5));
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
