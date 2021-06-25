import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

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
  final bool isRipple; // true为点击有波纹效果，false为点击有背景效果

  TapLayout({
    @required this.child,
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
    this.border,
    this.boxShadow,
    this.gradient,
    this.decorationImage,
    this.borderRadius,
    this.isRipple = true,
  });

  @override
  State<StatefulWidget> createState() => _TapLayoutState();
}

class _TapLayoutState extends State<TapLayout> {
  bool _isTouchDown = false;

  @override
  Widget build(BuildContext context) {
    final Color? color = widget.isRipple
        ? widget.background
        : _isTouchDown
            ? widget.foreground ?? Theme.of(context).highlightColor
            : widget.background;
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: color,
          borderRadius: widget.borderRadius,
          shape: BoxShape.rectangle,
          border: widget.border,
          boxShadow: widget.boxShadow,
          image: widget.decorationImage,
          gradient: widget.gradient,
        ),
        child: InkResponse(
          onTap: widget.onTap,
          onHighlightChanged: (value) => setState(() => _isTouchDown = value),
          onDoubleTap: widget.onDoubleTap,
          onLongPress: widget.onLongPress,
          borderRadius: widget.borderRadius,
          radius: widget.isRipple ? null : 0.0,
          highlightShape: BoxShape.rectangle,
          highlightColor: Colors.transparent,
          splashColor: widget.isRipple ? widget.foreground : Colors.transparent,
          containedInkWell: true,
          // 不要在这里设置背景色，否则会遮挡水波纹效果,如果设置的话尽量设置Material下面的color来实现背景色
          child: Container(
            // 设置child 居中
            alignment: widget.alignment,
            padding: widget.padding,
            width: widget.width,
            height: widget.height,
            margin: widget.margin,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
