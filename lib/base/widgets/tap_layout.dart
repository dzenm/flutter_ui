import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// 可点击布局
class TapLayout extends StatefulWidget {
  final Widget? child;
  final GestureTapCallback? onTap;

  final double? width;
  final double? height;

  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  final AlignmentGeometry alignment;

  final Color? normalColor;
  final Color? pressColor;

  final Color? rippleColor;
  final BorderRadius? borderRadius;
  final bool isRipple; // true为点击有波纹效果，false为点击有背景效果

  TapLayout({
    @required this.child,
    this.onTap,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.alignment = Alignment.center,
    this.normalColor = Colors.transparent,
    this.pressColor,
    this.rippleColor,
    this.borderRadius,
    this.isRipple = true,
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
        decoration: BoxDecoration(color: widget.normalColor, borderRadius: widget.borderRadius),
        child: InkResponse(
          borderRadius: widget.borderRadius,
          highlightColor: widget.pressColor,
          highlightShape: BoxShape.rectangle,
          radius: widget.isRipple ? 500.0 : 0.0,
          splashColor: widget.rippleColor,
          containedInkWell: true,
          onTap: widget.onTap,
          // 不要在这里设置背景色，否则会遮挡水波纹效果,如果设置的话尽量设置Material下面的color来实现背景色
          child: Container(
            width: widget.width,
            height: widget.height,
            margin: widget.margin,
            padding: widget.padding,
            // 设置child 居中
            alignment: widget.alignment,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
