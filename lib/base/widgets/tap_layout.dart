import 'package:flutter/material.dart';

/// 可点击布局
class TapLayout extends StatefulWidget {
  final Widget? child;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;

  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  final Color? foreground;
  final Color? background;

  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final DecorationImage? decorationImage;
  final BorderRadius? borderRadius;
  final bool isCircle; //是否为圆形

  final bool isRipple; // true为点击有波纹效果，false为点击有背景效果

  final int delay;

  TapLayout({
    Key? key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.width,
    this.height,
    this.margin,
    this.padding,
    this.alignment = Alignment.center,
    this.foreground,
    this.background = Colors.transparent,
    this.decorationImage,
    this.border,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
    this.isCircle = false,
    this.isRipple = true,
    this.delay = 150,
  });

  @override
  State<StatefulWidget> createState() => _TapLayoutState();
}

class _TapLayoutState extends State<TapLayout> {
  bool _isTouchDown = false;

  @override
  Widget build(BuildContext context) {
    final Color? color = widget.isRipple
        ? null
        : _isTouchDown
            ? widget.foreground ?? Theme.of(context).highlightColor
            : widget.background;

    double? radius = widget.isRipple ? null : 0.0;
    BoxShape shape = widget.isCircle ? BoxShape.circle : BoxShape.rectangle;
    Color? foreground = widget.isRipple && widget.onTap != null ? widget.foreground : Colors.transparent;

    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      // 设置形状
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        boxShadow: widget.boxShadow,
        borderRadius: widget.borderRadius,
        shape: shape,
      ),
      child: Material(
        color: Colors.transparent,
        animationDuration: Duration(milliseconds: widget.delay - 100),
        child: Ink(
          decoration: BoxDecoration(
            color: widget.background,
            gradient: widget.gradient,
            border: widget.border,
          ),
          child: InkResponse(
            onTap: () async => Future.delayed(Duration(milliseconds: widget.delay), () {
              if (widget.onTap != null) {
                widget.onTap!();
              }
            }),
            onLongPress: widget.onLongPress,
            onDoubleTap: widget.onDoubleTap,
            onHighlightChanged: (value) => setState(() => _isTouchDown = value),
            borderRadius: widget.borderRadius,
            radius: radius,
            highlightShape: shape,
            highlightColor: Colors.transparent,
            splashColor: foreground,
            containedInkWell: true,
            // 不要在这里设置背景色，否则会遮挡水波纹效果,如果设置的话尽量设置Material下面的color来实现背景色
            child: Container(
              decoration: BoxDecoration(
                color: color,
                image: widget.decorationImage,
                borderRadius: widget.borderRadius,
              ),
              // 设置child 居中
              alignment: widget.alignment,
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
