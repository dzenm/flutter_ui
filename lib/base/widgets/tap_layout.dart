import 'package:flutter/material.dart';

///
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
  final DecorationImage? image;
  final BorderRadius? borderRadius;
  final bool isCircle; //是否为圆形

  final bool isRipple; // true为点击有波纹效果，false为点击有背景效果

  final int delay;

  const TapLayout({
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
    this.image,
    this.border,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
    this.isCircle = false,
    this.isRipple = true,
    this.delay = 150,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TapLayoutState();
}

class _TapLayoutState extends State<TapLayout> {
  bool _isTouchDown = false;
  int _tapTime = 0;

  @override
  Widget build(BuildContext context) {
    bool isRipple = widget.isRipple;

    Widget child = Align(alignment: widget.alignment, child: widget.child);
    if (widget.padding != null) {
      child = Padding(padding: widget.padding!, child: child);
    }

    Color? foreground;
    Color? background;
    double? radius;
    if (isRipple) {
      if (widget.onTap != null) {
        foreground = widget.foreground;
      }
      background = widget.background;
    } else {
      foreground = Colors.transparent;
      Color touchBackground = widget.foreground ?? Theme.of(context).highlightColor;
      background = _isTouchDown ? touchBackground : widget.background;
      // 表示水波纹效果不显示
      radius = 0;
    }
    BoxShape shape = widget.isCircle ? BoxShape.circle : BoxShape.rectangle;
    child = Material(
      color: Colors.transparent,
      animationDuration: Duration(milliseconds: widget.delay - 100),
      clipBehavior: Clip.hardEdge,
      // 点击圆角
      borderRadius: widget.borderRadius,
      child: Ink(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          // 水波纹时的背景色
          color: background,
          image: widget.image,
          border: widget.border,
          borderRadius: widget.borderRadius,
          boxShadow: widget.boxShadow,
          gradient: widget.gradient,
          shape: shape,
        ),
        // 设置背景颜色
        child: InkResponse(
          onTap: () async => Future.delayed(Duration(milliseconds: widget.delay), () {
            int currentTime = DateTime.now().millisecondsSinceEpoch;
            if (currentTime - _tapTime > 500) {
              if (widget.onTap != null) widget.onTap!();
            }
            _tapTime = currentTime;
          }),
          onLongPress: widget.onLongPress,
          onDoubleTap: widget.onDoubleTap,
          onHighlightChanged: (value) => setState(() => _isTouchDown = value),
          // 水波纹圆角
          borderRadius: widget.borderRadius,
          radius: radius,
          highlightShape: shape,
          highlightColor: Colors.transparent,
          splashColor: foreground,
          containedInkWell: true,
          child: child,
        ),
      ),
    );

    if (widget.margin != null) {
      child = Padding(padding: widget.margin!, child: child);
    }
    return child;
  }
}
