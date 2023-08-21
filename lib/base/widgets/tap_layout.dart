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
  final AlignmentGeometry? alignment; // 设置Alignment.center会占用整行大小

  final Color? foreground;
  final Color? background;
  final Color? highlightColor;

  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final DecorationImage? image;
  final BorderRadius? borderRadius;
  final bool isCircle; //是否为圆形

  final bool isRipple; // true为点击有波纹效果，false为点击有背景效果

  final int delay;

  const TapLayout({
    super.key,
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
    this.highlightColor,
    this.image,
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
  int _tapTime = 0;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (widget.isRipple) {
      child = _buildRippleView();
    } else {
      child = _buildView();
    }
    if (widget.margin != null) {
      child = Padding(padding: widget.margin!, child: child);
    }
    return child;
  }

  /// 带有水波纹按钮的布局
  Widget _buildRippleView() {
    Widget child = widget.child!;
    if (widget.alignment != null) {
      child = Align(alignment: widget.alignment!, child: child);
    }
    if (widget.padding != null) {
      child = Padding(padding: widget.padding!, child: child);
    }
    BoxShape shape = widget.isCircle ? BoxShape.circle : BoxShape.rectangle;
    return DecoratedBox(
      decoration: BoxDecoration(
        image: widget.image,
        border: widget.border,
        borderRadius: widget.borderRadius,
        boxShadow: widget.boxShadow,
        gradient: widget.gradient,
        shape: shape,
      ),
      child: Material(
        color: Colors.transparent,
        // Widget展示的背景圆角，控件背景区域圆角以及水波纹扩散填充的圆角
        borderRadius: widget.borderRadius,
        clipBehavior: Clip.hardEdge,
        child: Ink(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.background,
            image: widget.image,
            border: widget.border,
            borderRadius: widget.borderRadius,
            boxShadow: widget.boxShadow,
            gradient: widget.gradient,
            shape: shape,
          ),
          // Widget展示的背景色
          child: InkResponse(
            onTap: () => _onTap(),
            onLongPress: widget.onLongPress,
            onDoubleTap: widget.onDoubleTap,
            onHighlightChanged: (value) => setState(() => _isTouchDown = value),
            // 点击时的水波纹圆角
            highlightShape: BoxShape.rectangle,
            borderRadius: widget.borderRadius,
            // 点击|触摸的时候,高亮显示的颜色
            highlightColor: widget.highlightColor ?? Theme.of(context).highlightColor,
            // 点击时的水波纹扩散颜色
            splashColor: widget.foreground ?? Theme.of(context).splashColor,
            containedInkWell: true,
            child: child,
          ),
        ),
      ),
    );
  }

  /// 没有水波纹按钮的布局
  Widget _buildView() {
    Color? color = widget.onTap == null
        ? widget.background
        : _isTouchDown
            ? widget.foreground ?? Theme.of(context).highlightColor
            : widget.background;
    return GestureDetector(
      onTap: () => _onTap(),
      onLongPress: widget.onLongPress,
      onDoubleTap: widget.onDoubleTap,
      onTapDown: (d) => setState(() => _isTouchDown = true),
      onTapUp: (d) => setState(() => _isTouchDown = false),
      onTapCancel: () => setState(() => _isTouchDown = false),
      child: Container(
        padding: widget.padding,
        alignment: widget.alignment,
        height: widget.height,
        width: widget.width,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: color,
          image: widget.image,
          border: widget.border,
          borderRadius: widget.borderRadius,
          boxShadow: widget.boxShadow,
          gradient: widget.gradient,
          shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
        ),
        child: widget.child,
      ),
    );
  }

  /// 点击事件
  void _onTap() {
    Future.delayed(Duration(milliseconds: widget.delay), () {
      // 短时间内禁止重复点击
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime - _tapTime > 500) {
        if (widget.onTap != null) widget.onTap!();
      }
      _tapTime = currentTime;
    });
  }
}
