import 'package:flutter/material.dart';

/// StrutStyle属性居中中文
class CenterText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextSpan? textSpan;

  const CenterText({
    super.key,
    required this.text,
    this.style,
    this.overflow,
    this.maxLines,
    this.textSpan,
  });

  @override
  Widget build(BuildContext context) {
    bool isTextSpan = textSpan != null;
    double textSize = (isTextSpan ? textSpan!.style?.fontSize : style?.fontSize) ?? 14.0;
    double textHeight = 1;
    if (textSize == 8) {
      textHeight = 0.7;
    } else if (textSize <= 10) {
      textHeight = 0.9;
    } else if (textSize < 14) {
      textHeight = 1 + (textSize - 10) * 0.05;
    } else if (textSize >= 14) {
      textHeight = (textSize - 1) * 0.1;
    }
    if (!isTextSpan) {
      return Text(
        text,
        style: style,
        overflow: overflow,
        maxLines: maxLines,
        textAlign: TextAlign.center,
        strutStyle: StrutStyle(
          fontSize: textSize,
          height: textHeight,
          forceStrutHeight: true,
        ),
      );
    }
    return RichText(
      text: textSpan!,
      textAlign: TextAlign.center,
      strutStyle: StrutStyle(
        fontSize: textSize,
        height: textHeight,
        forceStrutHeight: true,
      ),
    );
  }
}
