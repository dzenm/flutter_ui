import 'package:flutter/material.dart';

import 'tap_layout.dart';

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
