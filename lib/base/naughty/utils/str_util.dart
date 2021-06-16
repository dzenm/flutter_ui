import 'dart:convert';

import 'package:flutter/services.dart';

/// 字符串工具类
class StrUtil {
  /// 获取字符串所占用的字节大小
  static int getStringLength(String? str) {
    if (str == null || str.isEmpty) return 0;

    int len = 0;
    utf8.encode(str).forEach((ch) => len += ch > 256 ? 3 : 1);

    return len;
  }

  /// 格式化文件大小
  static String formatSize(int? len) {
    if (len == null) return '0 B';

    List<String> suffix = [" B", " KB", " MB", " GB", " TB", "PB"];

    int index = 0;
    // 因为要保存小数点，所以需大于102400以便用于后面进行小数分解的运算，index是判断以哪一个单位结尾
    while (len! >= 102400) {
      len ~/= 1024;
      index++;
    }

    int integer = len ~/ 100;
    int decimal = len % 100;
    bool isNeedDecimal = integer == 0 && decimal == 0;

    return '$integer${isNeedDecimal ? '' : '.$decimal'}${suffix[index]}';
  }

  // 复制到粘贴板
  static void copy(String? data) {
    if (data != null && data != '') {
      Clipboard.setData(ClipboardData(text: data));
    }
  }

  // 从粘贴板获取内容
  static Future<ClipboardData?> paste() async {
    return Clipboard.getData(Clipboard.kTextPlain);
  }
}
