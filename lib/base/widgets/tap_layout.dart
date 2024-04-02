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
  final Duration onTapDuration; // 点击的间隔时间
  final Duration delayedDuration; // 点击后延后的执行点击时间
  final Widget? child;

  TapLayout({
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
    Duration? onTapDuration,
    Duration? delayedDuration,
    required this.child,
  })  : onTapDuration = onTapDuration ?? const Duration(milliseconds: 500),
        delayedDuration = delayedDuration ?? const Duration(milliseconds: 50);

  @override
  Widget build(BuildContext context) {
    // 处理形状
    BoxShape shape = BoxShape.rectangle;
    // 处理宽高
    // 处理宽高
    double? w = width, h = height;
    if (isCircle) {
      if (width == null && height == null) {
        throw Exception('isCircle set true, width and height not both null');
      }
      w = h = width ?? height ?? 0;
      shape = BoxShape.circle;
    }

    Widget current = child!;
    if (alignment != null) {
      current = Align(alignment: alignment!, child: current);
    }
    if (padding != null) {
      current = Padding(padding: padding!, child: current);
    }

    if (isRipple) {
      current = _TapLayoutRipple(
        onTap: onTap == null ? null : _onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        onSecondaryTap: onSecondaryTap,
        width: w,
        height: h,
        foreground: foreground,
        background: background,
        highlightColor: highlightColor,
        image: image,
        borderRadius: borderRadius,
        gradient: gradient,
        shape: shape,
        child: current,
      );
    } else {
      current = _TapLayout(
        onTap: onTap == null ? null : _onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress,
        onSecondaryTap: onSecondaryTap,
        width: w,
        height: h,
        foreground: foreground,
        background: background,
        image: image,
        borderRadius: borderRadius,
        gradient: gradient,
        shape: shape,
        child: current,
      );
    }

    // 限制大小
    BoxConstraints? constraints = (w != null || h != null)
        ? this.constraints?.tighten(width: w, height: h) ?? BoxConstraints.tightFor(width: w, height: h) // 自定义的宽高
        : this.constraints;
    if (constraints != null) {
      current = ConstrainedBox(constraints: constraints, child: current);
    }

    // 增加边框和阴影
    if (border != null) {
      BoxDecoration decoration = BoxDecoration(
        border: border,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        shape: shape,
      );
      if (isCircle) {
        current = DecoratedBox(decoration: decoration, child: current);
      } else {
        // 不知道为什么，一定要用Container包裹才有效果
        current = Container(decoration: decoration, child: current);
      }
    }

    if (margin != null) {
      current = Padding(padding: margin!, child: current);
    }
    return current;
  }

  final ValueNotifier<DateTime> _tapTime = ValueNotifier(DateTime(1971));

  /// 点击事件
  void _onTap() {
    // 短时间内禁止重复点击
    DateTime now = DateTime.now();
    if (_tapTime.value.add(onTapDuration).isBefore(now)) {
      if (onTap != null) Future.delayed(delayedDuration, () => onTap!());
    }
    _tapTime.value = now;
  }
}

/// 普通点击布局
class _TapLayout extends StatelessWidget {
  final Widget? child;
  final GestureTapCallback? onTap;
  final GestureTapCallback? onDoubleTap;
  final GestureLongPressCallback? onLongPress;
  final GestureTapCallback? onSecondaryTap;
  final double? width;
  final double? height;
  final Color? foreground;
  final Color? background;
  final DecorationImage? image;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final BoxShape shape;

  _TapLayout({
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.width,
    this.height,
    this.foreground,
    this.background = Colors.transparent,
    this.image,
    this.borderRadius,
    this.gradient,
    required this.shape,
  });

  final ValueNotifier<bool> _isTouchDown = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return _buildView(context);
  }

  /// 没有水波纹按钮的布局
  Widget _buildView(BuildContext context) {
    return ValueListenableBuilder<bool>(
      builder: (context, isTouchDown, widget) {
        Color? color = onTap == null
            ? background
            : isTouchDown
                ? foreground ?? Theme.of(context).highlightColor
                : background;

        Widget current = child!;

        current = Container(
          height: height,
          width: width,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: color,
            image: image,
            borderRadius: borderRadius,
            gradient: gradient,
            shape: shape,
          ),
          child: current,
        );

        if (onTap != null || onLongPress != null || onDoubleTap != null || onSecondaryTap != null) {
          current = GestureDetector(
            onTap: onTap,
            onLongPress: onLongPress,
            onDoubleTap: onDoubleTap,
            onTapDown: (d) => _isTouchDown.value = true,
            onTapUp: (d) => _isTouchDown.value = false,
            onTapCancel: () => _isTouchDown.value = false,
            onSecondaryTap: onSecondaryTap,
            child: current,
          );
        }
        return current;
      },
      valueListenable: _isTouchDown,
    );
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
  final Color? foreground;
  final Color? background;
  final Color? highlightColor;
  final DecorationImage? image;
  final BorderRadius? borderRadius;
  final Gradient? gradient;
  final BoxShape shape;

  const _TapLayoutRipple({
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onSecondaryTap,
    this.width,
    this.height,
    this.foreground,
    this.background = Colors.transparent,
    this.highlightColor,
    this.image,
    this.borderRadius,
    this.gradient,
    required this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return _buildRippleView(context);
  }

  /// 带有水波纹按钮的布局
  Widget _buildRippleView(BuildContext context) {
    Color highlightColor = Platform.isAndroid || Platform.isIOS
        ? Colors.transparent // 鼠标高亮色
        : Theme.of(context).highlightColor;
    BorderRadius? effectiveBorderRadius = shape == BoxShape.circle
        ? BorderRadius.all(Radius.circular(width!)) // 水波纹的圆角
        : borderRadius;

    Widget current = child!;
    // 点击事件和前景色
    current = InkResponse(
      onTap: onTap,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      onSecondaryTap: onSecondaryTap,
      // 点击时的水波纹圆角
      highlightShape: shape,
      // 点击|触摸的时候,高亮显示的颜色
      highlightColor: this.highlightColor ?? highlightColor,
      // 点击时的水波纹扩散颜色
      splashColor: foreground ?? Theme.of(context).splashColor,
      borderRadius: effectiveBorderRadius,
      containedInkWell: true,
      child: current,
    );

    // 尺寸和背景色
    current = Ink(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: background,
        image: image,
        borderRadius: borderRadius,
        gradient: gradient,
        shape: shape,
      ),
      child: current,
    );

    // 必须在Material包裹下才会生效
    current = Material(
      color: Colors.transparent,
      borderRadius: borderRadius, // 设置圆角，包括水波纹、悬停、正常的圆角
      clipBehavior: Clip.hardEdge,
      child: current,
    );

    return current;
  }
}
