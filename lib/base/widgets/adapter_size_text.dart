import 'package:flutter/material.dart';
import 'dart:ui' as ui show TextHeightBehavior;

///
/// Created by a0010 on 2023/5/30 10:27
/// 在设置的行数 [maxLines] ，展示所有文本，如果超过限制，将自动调低文本的大小并且自己设置的文本大小 [TextStyle.fontSize] 将会失效
/// const AdapterSizeText(
///   '故常无欲，以观其妙，常有欲，以观其徼。',
///   style: TextStyle(color: Colors.red),
/// ),
/// const AdapterSizeText(
///   '此两者，同出而异名，同谓之玄，玄之又玄，众妙之门。',
///   style: TextStyle(color: Colors.red),
/// ),
class AdapterSizeText extends StatefulWidget {
  final String data;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final double? textScaleFactor;
  final int maxLines;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final ui.TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  const AdapterSizeText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.maxLines = 1,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  @override
  State<StatefulWidget> createState() => _AdapterSizeTextState();
}

class _AdapterSizeTextState extends State<AdapterSizeText> {
  final GlobalKey _key = GlobalKey();
  late TextStyle _style;
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.style?.fontSize ?? 15;
    _style = _createTextStyle(_fontSize);
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculatorTextFontSize(_fontSize));
  }

  /// 计算Text文本的大小
  void _calculatorTextFontSize(double fontSize) {
    RenderBox? textView = _key.currentContext?.findRenderObject() as RenderBox?;
    if (textView == null) return;
    Size size = textView.size;
    double width = size.width;
    // 重新创建调整后的样式
    _style = _createTextStyle(fontSize);
    // 判断文本是否超过最大行
    bool exceedMaxLines = _textExceedMaxLines(widget.data, _style, widget.maxLines, width);
    if (exceedMaxLines) {
      // 如果超过最大行，减小字体大小
      return _calculatorTextFontSize(--_fontSize);
    }

    // 当前字体大小在最大行能够完全放下，合并样式更新UI
    _style = widget.style?.copyWith(fontSize: _fontSize) ?? _createTextStyle(fontSize);
    setState(() {});
  }

  TextStyle _createTextStyle(double fontSize) {
    return TextStyle(fontSize: fontSize);
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.data,
      key: _key,
      style: _style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      locale: widget.locale,
      softWrap: widget.softWrap,
      overflow: widget.overflow,
      textScaleFactor: widget.textScaleFactor,
      maxLines: widget.maxLines,
      semanticsLabel: widget.semanticsLabel,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      selectionColor: widget.selectionColor,
    );
  }

  /// 判断文本是否超过规定的行数
  bool _textExceedMaxLines(String text, TextStyle textStyle, int maxLines, double maxWidth) {
    TextSpan textSpan = TextSpan(text: text, style: textStyle);
    TextPainter textPainter = TextPainter(text: textSpan, maxLines: maxLines, textDirection: TextDirection.ltr);
    textPainter.layout(maxWidth: maxWidth);
    if (textPainter.didExceedMaxLines) {
      return true;
    }
    return false;
  }
}
