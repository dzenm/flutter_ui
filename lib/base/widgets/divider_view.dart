import 'package:flutter/material.dart';

class DividerView extends StatelessWidget {
  final double height;
  final double width;
  final double indent;
  final double endIndent;
  final Color color;
  final Direction direction;

  const DividerView({
    super.key,
    this.height = 0.1,
    this.width = 0.1,
    this.indent = 0,
    this.endIndent = 0,
    this.color = const Color(0xFFF5F5F5),
    this.direction = Direction.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    switch (direction) {
      case Direction.vertical:
        return VerticalDivider(
          width: width,
          indent: indent,
          endIndent: endIndent,
          color: color,
        );
      case Direction.horizontal:
        return Divider(
          height: height,
          indent: indent,
          endIndent: endIndent,
          color: color,
        );
    }
  }
}

/// 方向
enum Direction {
  vertical,
  horizontal,
}
