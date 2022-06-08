import 'package:extended_text_field/extended_text_field.dart';
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
      final double size = 20.0;
      // fontSize 26 and text height = 30.0
      // final double fontSize = 26.0;
      return ImageSpan(
        AssetImage(EmojiUtil.instance.emojiMap[key] ?? ''),
        actualText: key,
        imageWidth: size,
        imageHeight: size,
        start: start,
        fit: BoxFit.fill,
        margin: EdgeInsets.only(
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
  final Map<String, String> _emojiMap = Map<String, String>();

  Map<String, String> get emojiMap => _emojiMap;

  final String _emojiFilePath = "assets/images";

  static EmojiUtil? _instance;

  static EmojiUtil get instance {
    if (_instance == null) {
      _instance = EmojiUtil._();
    }
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
