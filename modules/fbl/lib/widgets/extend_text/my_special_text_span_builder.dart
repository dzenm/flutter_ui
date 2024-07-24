import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/painting.dart';

import 'my_special_text.dart';

///
/// Created by a0010 on 2022/5/9 10:59
/// 特殊字符处理工厂
class MySpecialTextSpanBuilder extends SpecialTextSpanBuilder {
  /// whether show background for @somebody
  final bool showAtBackground;
  final BuilderType type;

  MySpecialTextSpanBuilder({this.showAtBackground = false, this.type = BuilderType.extendedText});

  @override
  TextSpan build(String data, {TextStyle? textStyle, onTap}) {
    var textSpan = super.build(data, textStyle: textStyle, onTap: onTap);
    //for performance, make sure your all SpecialTextSpan are only in textSpan.children
    //extended_text_field will only check SpecialTextSpan in textSpan.children
    return textSpan;
  }

  @override
  SpecialText? createSpecialText(String flag, {TextStyle? textStyle, SpecialTextGestureTapCallback? onTap, int? index}) {
    if (flag.isEmpty) return null;

    //
    ///index is end index of start flag, so text start index should be index-(flag.length-1)
    if (isStart(flag, EmojiText.flag)) {
      return EmojiText(textStyle!, start: index! - (EmojiText.flag.length - 1));
    } else if (isStart(flag, ImageText.flag)) {
      return ImageText(textStyle!, start: index! - (ImageText.flag.length - 1));
    }
    return null;
  }
}

// { /Users/a0010/Pictures/WX20231130-160703@2x.png }
enum BuilderType { extendedText, extendedTextField }
