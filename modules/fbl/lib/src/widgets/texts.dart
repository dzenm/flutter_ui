import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';

///
/// Created by a0010 on 2024/12/30 15:58
/// 展示文本类的通用组件
///

/// 文本居中展示布局
class CenterText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextOverflow? overflow;
  final int? maxLines;
  final TextSpan? textSpan;
  final bool isRichText;

  const CenterText(
    this.text, {
    super.key,
    this.style,
    this.overflow,
    this.maxLines,
    this.textSpan,
    this.isRichText = false,
  });

  @override
  Widget build(BuildContext context) {
    return !isRichText
        ? Text(
            text,
            style: style,
            overflow: overflow,
            maxLines: maxLines,
          )
        : RichText(
            text: textSpan ?? TextSpan(text: text, style: style),
            overflow: overflow ?? TextOverflow.clip,
            maxLines: maxLines,
            textAlign: TextAlign.center,
          );

    // int txtSize = type == 0 ? (style?.fontSize ?? 14).toInt() : (textSpan!.style?.fontSize ?? 14).toInt();
    //
    // double txtHeight = 1;
    // if (txtSize == 8) {
    //   txtHeight = 0.7;
    // } else if (txtSize <= 10) {
    //   txtHeight = 0.9;
    // } else if (txtSize < 14) {
    //   txtHeight = 1 + (txtSize - 10) * 0.05;
    // } else if (txtSize >= 14) {
    //   txtHeight = (txtSize - 1) * 0.1;
    // }
    // if (type == 0) {
    //   return Text(
    //     text,
    //     style: style,
    //     overflow: overflow,
    //     maxLines: maxLines,
    //     strutStyle: StrutStyle(
    //       fontSize: null,
    //       height: txtHeight,
    //       forceStrutHeight: true,
    //     ),
    //   );
    // }
    // return RichText(
    //   text: txtSpan!,
    //   textAlign: TextAlign.center,
    //   strutStyle: StrutStyle(
    //     fontSize: null,
    //     height: txtHeight,
    //     forceStrutHeight: true,
    //   ),
    // );
  }
}

abstract class VisualTextUtils {
  /// Calculate visual width
  static int getTextWidth(String text) {
    int width = 0;
    int index;
    int code;
    for (index = 0; index < text.length; ++index) {
      code = text.codeUnitAt(index);
      if (0x0000 <= code && code <= 0x007F) {
        // Basic Latin (ASCII)
        width += 1;
      } else if (0x0080 <= code && code <= 0x07FF) {
        // Latin-1 Supplement to CJK Unified Ideographs
        // ASCII or Latin-1 Supplement (includes most Western European languages)
        width += 1;
      } else {
        // Assume other characters are wide (e.g., CJK characters)
        width += 2;
      }
    }
    return width;
  }

  static String getSubText(String text, int maxWidth) {
    int width = 0;
    int index;
    int code;
    for (index = 0; index < text.length; ++index) {
      code = text.codeUnitAt(index);
      if (0x0000 <= code && code <= 0x007F) {
        // Basic Latin (ASCII)
        width += 1;
      } else if (0x0080 <= code && code <= 0x07FF) {
        // Latin-1 Supplement to CJK Unified Ideographs
        // ASCII or Latin-1 Supplement (includes most Western European languages)
        width += 1;
      } else {
        // Assume other characters are wide (e.g., CJK characters)
        width += 2;
      }
      if (width > maxWidth) {
        break;
      }
    }
    if (index == 0) {
      return '';
    }
    return text.substring(0, index);
  }
}

/// 自适应文本大小布局
/// 在设置的行数 [maxLines] ，展示所有文本，如果超过限制，将自动调低文本
/// 的大小并且自己设置的文本大小 [TextStyle.fontSize] 将会失效
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
  final TextScaler? textScale;
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
    this.textScale,
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
    WidgetsBinding.instance.addPostFrameCallback((_) => //
        _calculatorTextFontSize(_fontSize));
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
    bool exceedMaxLines = _isTextExceedMaxLines(widget.data, _style, widget.maxLines, width);
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
      textScaler: widget.textScale,
      maxLines: widget.maxLines,
      semanticsLabel: widget.semanticsLabel,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      selectionColor: widget.selectionColor,
    );
  }

  /// 判断文本是否超过规定的行数
  bool _isTextExceedMaxLines(
    String text,
    TextStyle textStyle,
    int maxLines,
    double maxWidth,
  ) {
    TextSpan textSpan = TextSpan(text: text, style: textStyle);
    TextPainter textPainter = TextPainter(
      text: textSpan,
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: maxWidth);
    if (textPainter.didExceedMaxLines) {
      return true;
    }
    return false;
  }
}
