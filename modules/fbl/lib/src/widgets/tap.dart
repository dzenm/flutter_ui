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
        hoverColor: highlightColor,
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
  final Color? hoverColor;
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
    this.hoverColor,
    this.image,
    this.borderRadius,
    this.gradient,
    required this.shape,
  });

  final ValueNotifier<bool> _isTouchDown = ValueNotifier(false);
  final ValueNotifier<bool> _isMouseEnter = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return _buildView(context);
  }

  /// 没有水波纹按钮的布局
  Widget _buildView(BuildContext context) {
    // 减少child的构建次数
    bool isExistTap = onTap != null || onLongPress != null || onDoubleTap != null || onSecondaryTap != null;
    Widget? current = child;
    if (!isExistTap) {
      // 设置悬停时的颜色
      current = ValueListenableBuilder<bool>(
        valueListenable: _isMouseEnter,
        child: current,
        builder: (context, isMouseEnter, child) {
          Color hover = Colors.transparent;
          if (isMouseEnter) {
            // 先处理鼠标进入区域事件
            hover = Platform.isAndroid || Platform.isIOS
                ? Colors.transparent // 鼠标高亮色
                : hoverColor ?? Theme.of(context).hoverColor; // 鼠标高亮色
          }
          if (hover == Colors.transparent) {
            return child!;
          }
          return ColoredBox(color: hover, child: child);
        },
      );
    }
    // 设置点击时的颜色
    current = ValueListenableBuilder<bool>(
      valueListenable: _isTouchDown,
      child: current,
      builder: (context, isTouchDown, child) {
        Color? color = background;
        if (isExistTap && isTouchDown) {
          // 再处理触摸点击事件
          color = foreground ?? Theme.of(context).highlightColor;
        }
        return Container(
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
          child: child,
        );
      },
    );
    if (!isExistTap) {
      return current;
    }
    // 设置鼠标事件和手势事件
    return MouseRegion(
      onEnter: (e) => _isMouseEnter.value = true,
      onExit: (e) => _isMouseEnter.value = false,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        onDoubleTap: onDoubleTap,
        onTapDown: (e) => _isTouchDown.value = true,
        onTapUp: (e) => _isTouchDown.value = false,
        onTapCancel: () => _isTouchDown.value = false,
        onSecondaryTap: onSecondaryTap,
        child: current,
      ),
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
    bool isCircle = shape == BoxShape.circle;
    Color highlightColor = Platform.isAndroid || Platform.isIOS
        ? Colors.transparent // 鼠标高亮色
        : Theme.of(context).highlightColor;
    BorderRadius? effectiveBorderRadius = isCircle
        ? BorderRadius.all(Radius.circular(width ?? height ?? 0)) // 水波纹的圆角
        : borderRadius;

    Widget current = child!;
    // 点击事件和前景色
    current = InkResponse(
      onTap: onTap,
      onLongPress: onLongPress,
      onDoubleTap: onDoubleTap,
      onSecondaryTap: onSecondaryTap,
      // 不设置不行
      highlightShape: shape,
      // 点击|触摸的时候,高亮显示的颜色
      highlightColor: this.highlightColor ?? highlightColor,
      // 点击时的水波纹扩散颜色
      splashColor: foreground ?? Theme.of(context).splashColor,
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
        gradient: gradient,
      ),
      child: current,
    );

    // 必须在Material包裹下才会生效
    current = Material(
      color: Colors.transparent,
      borderRadius: effectiveBorderRadius,
      // 设置圆角，包括水波纹、悬停、正常的圆角
      clipBehavior: Clip.hardEdge,
      type: isCircle ? MaterialType.circle : MaterialType.canvas,
      child: current,
    );

    return current;
  }
}

class WrapButton extends StatelessWidget {
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final String? text;
  final Widget? child;
  final VoidCallback? onTap;
  final TextStyle? style;
  final Color? color;
  final List<BoxShadow>? boxShadow;
  final double radius;
  final bool isBorder;
  final int borderColor;
  final Gradient? gradient;
  final bool enable;

  const WrapButton({
    super.key,
    this.width,
    this.height = 40.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 5.0),
    this.margin,
    this.text,
    this.child,
    this.onTap,
    this.style,
    this.color,
    this.boxShadow,
    this.radius = 5.0,
    this.isBorder = false,
    this.gradient,
    this.borderColor = 0xffFC6973,
    this.enable = true,
  });

  @override
  Widget build(BuildContext context) {
    double opacity = enable ? 1 : 0.6;
    Color defaultColor = const Color.fromRGBO(225, 225, 225, 1.0);
    Gradient defaultGradient = gradient ??
        LinearGradient(colors: [
          Color.fromRGBO(8, 191, 98, opacity),
          Color.fromRGBO(8, 191, 98, opacity),
        ]);
    return TapLayout(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      onTap: enable ? onTap : null,
      background: color ?? defaultColor,
      gradient: color == null ? defaultGradient : null,
      boxShadow: boxShadow,
      border: isBorder ? Border.all(width: 0.5, color: Color(borderColor)) : null,
      borderRadius: BorderRadius.all(Radius.circular(radius)),
      child: text == null ? child : Text('$text', style: style ?? TextStyle(fontSize: 15.0, color: defaultColor)),
    );
  }
}

