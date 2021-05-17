import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// 可点击布局
class TapLayout extends StatefulWidget {
  final Widget? child;
  final Color? normalColor;
  final Color? pressColor;
  final Color? rippleColor;
  final BorderRadius? borderRadius;
  final GestureTapCallback? onTap;
  final double? width;
  final double? height;
  final bool isRipple;

  TapLayout({
    @required this.child,
    this.normalColor,
    this.pressColor,
    this.rippleColor,
    this.borderRadius,
    this.onTap,
    this.width,
    this.height,
    this.isRipple = false,
  });

  @override
  State<StatefulWidget> createState() => _TapLayoutState();
}

class _TapLayoutState extends State<TapLayout> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: widget.normalColor ?? Colors.white,
          borderRadius: widget.borderRadius,
        ),
        child: InkResponse(
          borderRadius: widget.borderRadius,
          highlightColor: widget.pressColor,
          highlightShape: BoxShape.rectangle,
          radius: widget.isRipple ? 0.0 : 500.0,
          splashColor: widget.rippleColor,
          containedInkWell: true,
          onTap: widget.onTap,
          // 不要在这里设置背景色，否则会遮挡水波纹效果,如果设置的话尽量设置Material下面的color来实现背景色
          child: Container(
            width: widget.width,
            height: widget.height,
            alignment: Alignment(0, 0), // 设置child 居中
            child: widget.width == null ? widget.child : Row(children: [widget.child!],),
          ),
        ),
      ),
    );
  }
}
