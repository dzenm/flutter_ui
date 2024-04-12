import 'dart:io';

import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

///
/// Created by a0010 on 2022/5/9 09:37
/// 展示输入框内表情字符
class EmojiText extends SpecialText {
  static const String flag = "[";
  final int start;

  EmojiText(TextStyle textStyle, {required this.start}) : super(EmojiText.flag, "]", textStyle);

  @override
  InlineSpan finishText() {
    String key = toString();
    if (EmojiUtil.instance.emojiMap.containsKey(key)) {
      // size = 30.0/26.0 * fontSize
      const double size = 20.0;
      // fontSize 26 and text height = 30.0
      // final double fontSize = 26.0;
      return ImageSpan(
        AssetImage(EmojiUtil.instance.emojiMap[key] ?? ''),
        actualText: key,
        imageWidth: size,
        imageHeight: size,
        start: start,
        fit: BoxFit.fill,
        margin: const EdgeInsets.only(
          left: 2.0,
          top: 2.0,
          right: 2.0,
        ),
      );
    }
    return TextSpan(text: toString(), style: textStyle);
  }
}

// 表情工具类，获取表情
class EmojiUtil {
  final Map<String, String> _emojiMap = {};

  Map<String, String> get emojiMap => _emojiMap;

  final String _emojiFilePath = "assets/images";

  static EmojiUtil? _instance;

  static EmojiUtil get instance {
    _instance ??= EmojiUtil._();
    return _instance!;
  }

  EmojiUtil._() {
    _emojiMap["[a]"] = "$_emojiFilePath/a.jpg";
    _emojiMap["[b]"] = "$_emojiFilePath/b.jpg";
    _emojiMap["[c]"] = "$_emojiFilePath/c.jpg";
    _emojiMap["[d]"] = "$_emojiFilePath/d.jpg";
    _emojiMap["[e]"] = "$_emojiFilePath/e.jpg";
  }
}

class ImageText extends SpecialText {
  static const String flag = leftFlag;
  static const String leftFlag = '{';
  static const String rightFlag = '}';
  final int start;

  ImageText(TextStyle textStyle, {required this.start}) : super(ImageText.flag, rightFlag, textStyle);

  @override
  InlineSpan finishText() {
    // {/Users/a0010/Pictures/WX20231130-160703@2x.png}
    String text = toString();
    String path = '';
    if (text.startsWith(leftFlag) && text.endsWith(rightFlag)) {
      path = text.substring(leftFlag.length, text.length - rightFlag.length);
    }

    File file = File(path);
    if (file.existsSync()) {
      const double width = 108.0;
      const double height = 72.0;
      // 判断文件是否存在，存在才展示
      return ImageSpan(
        MemoryImage(file.readAsBytesSync()),
        actualText: path,
        imageWidth: width,
        imageHeight: height,
        start: start,
        fit: BoxFit.fill,
        margin: const EdgeInsets.only(
          left: 4.0,
          top: 2.0,
          right: 4.0,
        ),
      );
    }
    return TextSpan(text: text, style: textStyle);
  }
}

class AtText extends SpecialText {
  static const String flag = '@';
  final int start;

  AtText(TextStyle textStyle, {required this.start}) : super(AtText.flag, ' ', textStyle);

  @override
  InlineSpan finishText() {
    String key = toString();
    if (EmojiUtil.instance.emojiMap.containsKey(key)) {
      // size = 30.0/26.0 * fontSize
      const double size = 20.0;
      // fontSize 26 and text height = 30.0
      // final double fontSize = 26.0;
      return ImageSpan(
        AssetImage(EmojiUtil.instance.emojiMap[key] ?? ''),
        actualText: key,
        imageWidth: size,
        imageHeight: size,
        start: start,
        fit: BoxFit.fill,
        margin: const EdgeInsets.only(
          left: 2.0,
          top: 2.0,
          right: 2.0,
        ),
      );
    }
    return TextSpan(text: toString(), style: textStyle);
  }
}
