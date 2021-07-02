import 'package:flutter/material.dart';

class ComMomButton extends StatelessWidget {
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final String? text;
  final VoidCallback? onTap;
  final TextStyle? style;
  final Color? color;
  final List<BoxShadow>? boxShadow;
  final double radius;
  final bool isBorder;
  final int borderColor;
  final Gradient gradient;
  final bool enable;

  ComMomButton({
    this.width,
    this.height = 40.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 5.0),
    this.margin,
    this.text,
    this.onTap,
    this.style,
    this.color,
    this.boxShadow,
    this.radius = 5.0,
    this.isBorder = false,
    this.gradient = const LinearGradient(
      colors: [
        Color.fromRGBO(8, 191, 98, 1.0),
        Color.fromRGBO(8, 191, 98, 1.0),
      ],
    ),
    this.borderColor = 0xffFC6973,
    this.enable = true,
  });

  @override
  Widget build(BuildContext context) {
    Color _color = Color.fromRGBO(225, 225, 225, enable ? 1 : 0.3);

    return Container(
      margin: margin,
      child: InkWell(
        child: Container(
          alignment: Alignment.center,
          padding: padding,
          width: width,
          height: height,
          decoration: color == null
              ? BoxDecoration(
                  gradient: gradient,
                  boxShadow: boxShadow,
                  border: isBorder ? Border.all(width: 0.5, color: Color(borderColor)) : null,
                  borderRadius: BorderRadius.all(
                    Radius.circular(radius),
                  ),
                )
              : BoxDecoration(
                  color: color,
                  boxShadow: boxShadow,
                  border: isBorder ? Border.all(width: 0.5, color: Color(borderColor)) : null,
                  borderRadius: BorderRadius.all(
                    Radius.circular(radius),
                  ),
                ),
          child: Text(
            '$text',
            style: style != null ? style : TextStyle(fontSize: 15.0, color: _color),
          ),
        ),
        onTap: enable ? onTap : () {},
      ),
    );
  }
}
