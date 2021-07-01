import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

/// 字符串工具类
class StrUtil {
  /// 获取文件名通过路径或者文件
  static String getFileName(dynamic file) {
    String path = '';
    if (file is File) {
      path = file.path;
    } else {
      path = file.toString();
    }
    return path.split('/').last;
  }

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

  /// 格式化字符串, 如果需要将 [Map] 或 [List] 转为 [String], 使用 [jsonEncode(object)]
  static String formatToJson(dynamic message) {
    String str = '';
    if (message is Map || message is List) {
      str = jsonEncode(message);
    } else {
      str = message.toString();
    }
    try {
      return JsonEncoder.withIndent('  ').convert(json.decode(str));
    } catch (e) {
      return str;
    }
  }
}
