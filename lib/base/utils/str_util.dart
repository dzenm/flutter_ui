import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

///
/// Created by a0010 on 2022/3/22 09:38
/// 字符串工具类
///
class StrUtil {
  /// 汉字的星期日期
  static List<String> chineseCharacterWeeks = ['一', '二', '三', '四', '五', '六', '七'];

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
      return const JsonEncoder.withIndent('  ').convert(json.decode(str));
    } catch (e) {
      return str;
    }
  }

  /// 将string转化成list
  static List<String> stringToList(String? s, {String pattern = ','}) {
    List<String> list = [];
    s?.split(pattern).forEach((cookie) => list.add(cookie));
    return list;
  }

  /// 将string转化成list
  static String listToString(List<String>? list, {String pattern = ','}) {
    StringBuffer sb = StringBuffer();
    list?.forEach((cookie) => sb
      ..write(cookie)
      ..write(pattern));
    return sb.toString();
  }

  /// 计算 [before] 在当前时间的多久之前，如果是一天前，按天数展示，如果是一天内，按小时展示，如果是一小时内，按分钟展示
  /// [showDate] 为true七天前的按具体日期展示，否则按七天前展示
  /// [showTime] 为true一天内的按小时或分钟展示，否则几天前展示
  static String todayBefore(DateTime before, {bool showDate = false, bool showTime = false}) {
    DateTime today = DateTime.now();
    // 以当前时间为基准，获取一周内这个时间的DateTime
    List<DateTime> days = List.generate(7, (index) => today.subtract(Duration(days: index + 1)));
    // 计算在几天前
    int index = -1;
    for (int i = 0; i < days.length; i++) {
      DateTime date = days[i];
      if (before.year == date.year && before.month == date.month && before.day == date.day) {
        index = i;
        break;
      }
    }
    if (index == -1) {
      if (showDate) return '${before.year}/${before.month}/${before.day}';
      index = days.length - 1;
    }
    // 在一天前，直接按天处理
    if (index > 1) return '${chineseCharacterWeeks[index]}天前';
    if (!showTime) return '今天';

    List<DateTime> hours = List.generate(24, (index) => today.subtract(Duration(hours: index + 1)));
    List<DateTime> minutes = List.generate(60, (index) => today.subtract(Duration(minutes: index + 1)));
    // 在一天内，按小时处理
    for (int i = 0; i < hours.length; i++) {
      // 判断小时是否相等
      if (before.hour != hours[i].hour) continue;
      // 在一小时前，直接按小时处理
      if (i > 0) return '$i小时前';
      // 在一小时内，按分钟处理
      for (int j = 0; j < minutes.length; j++) {
        // 判断分钟是否相等
        if (before.minute != minutes[j].minute) continue;
        // 在一分钟内，按1分钟内处理
        return '${j > 0 ? j : 1}分前';
      }
    }
    return '';
  }
}
