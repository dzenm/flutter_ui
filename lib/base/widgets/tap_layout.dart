import 'dart:io';

import 'package:flutter/material.dart';

///
/// 可点击布局
///
class TapLayout extends StatelessWidget {
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onSecondaryTap;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment; // 设置Alignment.center会占用整行大小，此时可以设置alignment为null
  final Color? foreground;
  final Color? background;
  final Color? highlightColor;
  final DecorationImage? image;
  final BoxBorder? border;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final bool isCircle; //是否为圆形
  final bool isRipple; // true为点击有波纹效果，false为点击有背景效果
  final int delay;
  final Widget? child;

  const TapLayout({
    super.key,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.width,
    this.height,
    this.constraints,
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
    this.isRipple = false,
    this.delay = 100,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = this.child!;
    if (onTap == null) {}
    if (isRipple) {
      child = _TapLayoutRipple(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        onSecondaryTap: onSecondaryTap,
        width: width,
        height: height,
        padding: padding,
        alignment: alignment,
        foreground: foreground,
        background: background,
        highlightColor: highlightColor,
        image: image,
        border: border,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        gradient: gradient,
        isCircle: isCircle,
        delay: delay,
        child: child,
      );
    } else {
      child = _TapLayout(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        onSecondaryTap: onSecondaryTap,
        width: width,
        height: height,
        padding: padding,
        alignment: alignment,
        foreground: foreground,
        background: background,
        image: image,
        border: border,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        gradient: gradient,
        isCircle: isCircle,
        delay: delay,
        child: child,
      );
    }

    if (constraints != null) {
      child = ConstrainedBox(constraints: constraints!, child: child);
    }
    if (margin != null) {
      child = Padding(padding: margin!, child: child);
    }
    return child;
  }
}

/// 普通点击布局
class _TapLayout extends StatefulWidget {
  final Widget? child;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onSecondaryTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment; // 设置Alignment.center会占用整行大小
  final Color? foreground;
  final Color? background;
  final DecorationImage? image;
  final BoxBorder? border;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final bool isCircle; //是否为圆形
  final int delay;

  const _TapLayout({
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.width,
    this.height,
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
    this.delay = 150,
  });

  @override
  State<StatefulWidget> createState() => _TapLayoutState();
}

class _TapLayoutState extends State<_TapLayout> {
  bool _isTouchDown = false;
  int _tapTime = 0;

  @override
  Widget build(BuildContext context) {
    return _buildView();
  }

  /// 没有水波纹按钮的布局
  Widget _buildView() {
    Color? color = widget.onTap == null
        ? widget.background
        : _isTouchDown
            ? widget.foreground ?? Theme.of(context).highlightColor
            : widget.background;
    Widget child = Container(
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
    );
    if (widget.onTap == null) {
      return child;
    }
    return _buildTapView(child);
  }

  Widget _buildTapView(Widget child) {
    return GestureDetector(
      onTap: () => _onTap(),
      onLongPress: widget.onLongPress,
      onDoubleTap: widget.onDoubleTap,
      onTapDown: (d) => setState(() => _isTouchDown = true),
      onTapUp: (d) => setState(() => _isTouchDown = false),
      onTapCancel: () => setState(() => _isTouchDown = false),
      onSecondaryTap: widget.onSecondaryTap,
      child: child,
    );
  }

  /// 点击事件
  void _onTap() {
    // 短时间内禁止重复点击
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - _tapTime > 500) {
      if (widget.onTap != null) widget.onTap!();
    }
    _tapTime = currentTime;
  }
}

/// 水波纹点击布局
class _TapLayoutRipple extends StatelessWidget {
  final Widget? child;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onSecondaryTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry? alignment; // 设置Alignment.center会占用整行大小
  final Color? foreground;
  final Color? background;
  final Color? highlightColor;
  final DecorationImage? image;
  final BoxBorder? border;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final bool isCircle; //是否为圆形
  final int delay;

  _TapLayoutRipple({
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.width,
    this.height,
    this.padding,
    this.alignment,
    this.foreground,
    this.background = Colors.transparent,
    this.highlightColor,
    this.image,
    this.border,
    this.borderRadius,
    this.boxShadow,
    this.gradient,
    this.isCircle = false,
    this.delay = 150,
  });

  int _tapTime = 0;

  @override
  Widget build(BuildContext context) {
    return _buildRippleView(context);
  }

  /// 带有水波纹按钮的布局
  Widget _buildRippleView(BuildContext context) {
    // 处理圆角和形状
    BorderRadius? borderRadius = this.borderRadius;
    BoxShape shape = BoxShape.rectangle;
    // 处理宽高
    double? w = width, h = height;
    if (isCircle) {
      if (width == null && height == null) {
        throw Exception('isCircle set true, width and height not both null');
      }
      if (width == null) {
        w = h = height!;
      } else if (height == null) {
        w = h = width!;
      }
      borderRadius = BorderRadius.all(Radius.circular(w ?? 0));
      shape = BoxShape.circle;
    }
    Color highlightColor = Platform.isAndroid || Platform.isIOS ? Colors.transparent : Theme.of(context).highlightColor;

    Widget child = this.child!;
    if (alignment != null) {
      child = Align(alignment: alignment!, child: child);
    }
    if (padding != null) {
      child = Padding(padding: padding!, child: child);
    }

    // 点击事件和前景色
    child = InkResponse(
      onTap: () => _onTap(),
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      onSecondaryTap: onSecondaryTap,
      // 点击时的水波纹圆角
      highlightShape: shape,
      // 点击|触摸的时候,高亮显示的颜色
      highlightColor: this.highlightColor ?? highlightColor,
      // 点击时的水波纹扩散颜色
      splashColor: foreground ?? Theme.of(context).splashColor,
      containedInkWell: true,
      child: child,
    );

    // 尺寸和背景色
    child = Ink(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: background,
        image: image,
        border: border,
        borderRadius: isCircle ? null : borderRadius,
        boxShadow: boxShadow,
        gradient: gradient,
        shape: shape,
      ),
      child: child,
    );

    // 必须在Material包裹下才会生效
    child = Material(
      color: Colors.transparent,
      borderRadius: borderRadius, // 设置圆角，包括水波纹、悬停、正常的圆角
      clipBehavior: Clip.hardEdge,
      child: child,
    );

    return child;
  }

  /// 点击事件
  void _onTap() {
    // 短时间内禁止重复点击
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    if (currentTime - _tapTime > delay) {
      if (onTap != null) onTap!();
    }
    _tapTime = currentTime;
  }
}
