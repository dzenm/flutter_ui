import 'dart:math' as math;

import 'package:flutter/material.dart';

///
/// Created by a0010 on 2025/9/16 11:31
/// 五角星评价
class StarsView extends StatefulWidget {
  /// 评价的最高级别，一颗五角星代表一个级别
  final int maxLevel;

  /// 两个五角星之间的距离
  final double distance;

  /// 评价变化的回调
  final ValueChanged<int> onChanged;

  const StarsView({
    super.key,
    this.maxLevel = 5,
    this.distance = 8,
    required this.onChanged,
  });

  @override
  State<StarsView> createState() => _StarsViewState();
}

class _StarsViewState extends State<StarsView> {
  List<bool> _list = [];

  @override
  void initState() {
    super.initState();
    _list = List.generate(widget.maxLevel, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return _buildChildren();
  }

  Widget _buildChildren() {
    List<bool> list = _list;
    List<Widget> children = [];
    for (var i = 0; i < list.length; i++) {
      children.add(_buildChild(i));
      if (i >= list.length - 1) continue;
      children.add(SizedBox(width: widget.distance)); // 增加左右的边距
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }

  Widget _buildChild(int index) {
    List<bool> list = _list;
    bool isSelected = list[index];
    return GestureDetector(
      onTap: () {
        for (var i = 0; i < list.length; i++) {
          list[i] = i <= index;
        }
        widget.onChanged(index + 1);
        setState(() {});
      },
      child: Polygonal(color: isSelected ? Colors.blue : Colors.grey),
    );
  }
}

/// 多边形的形状
enum PolygonShape {
  angle, // 多角形
  side, // 多边形
  all; // 边和角都存在

  bool get containsAngle => [
        PolygonShape.angle,
        PolygonShape.all,
      ].contains(this); // 是否包含角
  bool get containsSide => [
        PolygonShape.side,
        PolygonShape.all,
      ].contains(this); // 是否包含边
}

/// 多边形
class Polygonal extends StatelessWidget {
  final Size size; // 大小
  final double? externalRadius; // 外圆半径
  final double? innerRadius; // 内圆半径
  final int count; // 根据数量确定多边形
  final PolygonShape shape; // 多边形的形状
  final PolygonStyle style; // 填充的样式
  final double strokeWidth; // 边框的大小
  final Color color; // 颜色

  const Polygonal({
    super.key,
    this.size = const Size(40, 40),
    this.externalRadius,
    this.innerRadius,
    this.count = 5,
    this.shape = PolygonShape.angle,
    this.style = PolygonStyle.fill,
    this.strokeWidth = 0,
    this.color = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _PolygonalPainter(
        externalRadius,
        innerRadius,
        count: count,
        shape: PolygonShape.angle,
        style: style,
        strokeWidth: strokeWidth,
        color: color,
      ),
    );
  }
}

/// 多边形的样式
enum PolygonStyle {
  fill, // 全部填充
  stroke; // 内部不填充，只有边框

  bool get isFill => [PolygonStyle.fill].contains(this); // 是否填充
}

/// 多边形绘制
class _PolygonalPainter extends CustomPainter {
  final double? externalRadius; // 外圆半径
  final double? innerRadius; // 内圆半径
  final int count; // 根据数量确定多边形
  final PolygonShape shape; // 多边形的形状
  final PolygonStyle style; // 填充的样式
  final double strokeWidth; // 边框的大小
  final Color color; // 颜色
  _PolygonalPainter(
    this.externalRadius,
    this.innerRadius, {
    this.count = 5,
    this.shape = PolygonShape.angle,
    this.style = PolygonStyle.fill,
    this.strokeWidth = 2,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);
    canvas.translate(size.width / 2, size.height / 2);
    Paint paint2 = Paint()
      ..color = color
      ..strokeJoin = StrokeJoin.round
      ..style = style.isFill ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double r1 = externalRadius ?? (size.width / 2);
    double r2 = innerRadius ?? (size.width / 2 - 12);
    // 将圆等分
    Path path = Path();
    canvas.rotate(math.pi / count + math.pi / 2 * 3);
    path.moveTo(
      r1 * math.cos(math.pi / count),
      r1 * math.sin(math.pi / count),
    );

    /// 绘制角
    if (shape.containsAngle) {
      for (int i = 2; i <= count * 2; i++) {
        if (i.isEven) {
          path.lineTo(
            r2 * math.cos(math.pi / count * i),
            r2 * math.sin(math.pi / count * i),
          );
        } else {
          path.lineTo(
            r1 * math.cos(math.pi / count * i),
            r1 * math.sin(math.pi / count * i),
          );
        }
      }
      path.close();
      canvas.drawPath(path, paint2);
    }

    /// 绘制边
    if (shape.containsSide) {
      path.reset();
      path.moveTo(
        r1 * math.cos(math.pi / count),
        r1 * math.sin(math.pi / count),
      );
      for (int i = 2; i <= count * 2; i++) {
        if (i.isOdd) {
          path.lineTo(
            r1 * math.cos(math.pi / count * i),
            r1 * math.sin(math.pi / count * i),
          );
        }
      }
      path.close();
      canvas.drawPath(path, paint2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
