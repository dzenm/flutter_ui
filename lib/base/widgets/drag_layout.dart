import 'dart:ui';

import 'package:flutter/material.dart';

/// 在屏幕范围内的拖动布局, 不超过范围
class DragLayout extends StatefulWidget {
  final Widget? child;
  final GestureTapCallback? onTap;
  final double width;
  final double height;

  const DragLayout({
    super.key,
    this.child,
    this.onTap,
    this.width = 64.0,
    this.height = 64.0,
  });

  @override
  State<StatefulWidget> createState() => _DragLayoutState();
}

class _DragLayoutState extends State<DragLayout> {
  // 当前悬浮窗的位置
  Offset realPosition = const Offset(0, kToolbarHeight + 64);

  @override
  void initState() {
    super.initState();
  }

  Offset _dragWidget(Offset lastPosition, Offset offset) {
    double statusBarHeight = MediaQueryData.fromWindow(window).padding.top;
    Size size = MediaQuery.of(context).size;

    double dx = lastPosition.dx + offset.dx;
    if (dx <= 0) {
      dx = 0;
    } else if (dx >= size.width - widget.width) {
      dx = size.width - widget.width;
    }
    double dy = lastPosition.dy + offset.dy;
    if (dy <= statusBarHeight) {
      dy = statusBarHeight;
    } else if (dy >= size.height - kToolbarHeight) {
      dy = size.height - kToolbarHeight;
    }
    return Offset(dx, dy);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialBannerTheme(
      child: Positioned(
        left: realPosition.dx,
        top: realPosition.dy,
        child: GestureDetector(
          // 手指按下 位置(e.globalPosition)
          onPanDown: (DragDownDetails details) {},
          // 手指滑动
          onPanUpdate: (DragUpdateDetails details) {
            setState(() => realPosition = _dragWidget(realPosition, details.delta));
          },
          // 手指滑动结束
          onPanEnd: (DragEndDetails details) {},
          onTap: widget.onTap,
          child: widget.child,
        ),
      ),
    );
  }
}
