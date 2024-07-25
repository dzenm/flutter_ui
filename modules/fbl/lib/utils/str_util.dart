import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

///
/// Created by a0010 on 2022/3/22 09:38
/// 字符串工具类
class StrUtil {
  /// 汉字的星期日期
  static List<String> chineseCharacterWeeks = ['一', '二', '三', '四', '五', '六', '七'];

  /// 获取字符串所占用的字节大小
  static int getStringLength(String? str) {
    if (str == null || str.isEmpty) return 0;

    int len = 0;
    utf8.encode(str).forEach((ch) => len += ch > 256 ? 3 : 1);

    return len;
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

  /// 将string转化成list，例：
  ///
  /// str = loginUserName=FreedomEden; &token_pass=43ccc3e2db90ae005b0113683b07aabb;
  /// &loginUserName_wanandroid_com=FreedomEden; &token_pass_wanandroid_com=43ccc3e2db90ae005b0113683b07aabb; &
  ///
  /// List<String> = ["loginUserName=FreedomEden; ","token_pass=43ccc3e2db90ae005b0113683b07aabb; ",
  /// "loginUserName_wanandroid_com=FreedomEden; ","token_pass_wanandroid_com=43ccc3e2db90ae005b0113683b07aabb; ",""]
  static List<String> stringToList(String? s, {String pattern = ','}) {
    List<String> list = [];
    s?.split(pattern).forEach((cookie) => list.add(cookie));
    return list;
  }

  /// 将string转化成list  @see [stringToList]
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

  /// 字符串转int，如果不是为null或者包含非数字字符，结果为[defaultValue]
  static int parseInt(String? source, {int defaultValue = 0}) {
    if (source == null) return defaultValue;
    try {
      return int.parse(source);
    } catch (e) {
      return defaultValue;
    }
  }

  /// 字符串转double，如果不是为null或者包含非数字字符，结果为[defaultValue]
  static double parseDouble(String? source, {double defaultValue = 0}) {
    if (source == null) return defaultValue;
    try {
      return double.parse(source);
    } catch (e) {
      return defaultValue;
    }
  }

  /// 校验参数
  static const String secretCode = 'SeCreTCode';

  /// 将校验参数的每一位字符隔三位插入随机数中，最后转换为base64码
  static String generateRandomCode(String random) {
    List<String> randoms = List.generate(random.length, (index) => random[index]);
    for (int i = 0; i < secretCode.length; i++) {
      randoms.insert(i * 3 + 1, secretCode[i]);
    }

    // 将字符数组转为字符串
    String code = randoms.join('');
    return code;
  }

  /// 生成一个随机字符数
  static String generateUUidString() {
    List<String> randoms = [];
    String hexDigits = '0123456789abcdef';
    for (int i = 0; i < 36; i++) {
      int index = Random().nextInt(15);
      randoms.add(hexDigits.substring(index, index + 1));
    }
    return List.generate(randoms.length, (i) => randoms[i]).join('');
  }

  /// 生成二维码字符
  static String generateQRCode(String uuid) {
    String suf = '?md=webscan&uid=';
    return '$suf$uuid';
  }

  /// 生成一个32位的随机uuid，前19位是随机数，后13位是当前时间戳
  static String generateUuidNumber() {
    String randomStr = '';
    for (int i = 0; i < 19; i++) {
      int str = Random().nextInt(10);
      randomStr += '$str';
    }
    int time = DateTime.now().millisecondsSinceEpoch;
    return '$randomStr$time';
  }

  /// Generates a RNG version 4 UUID
  static String generateUid() {
    // Use provided values over RNG
    var uid = mathRNG();
    // per 4.4, set bits for version and clockSeq high and reserved
    uid[6] = (uid[6] & 0x0f) | 0x40;
    uid[8] = (uid[8] & 0x3f) | 0x80;
    return bytes2String(uid, 0, uid.length);
  }

  /// Math.Random()-based RNG. All platforms, fast, not cryptographically strong. Optional Seed passable.
  static List<int> mathRNG({int seed = -1}) {
    final b = Uint8List(16);
    final rand = (seed == -1) ? Random() : Random(seed);
    for (var i = 0; i < 16; i++) {
      b[i] = rand.nextInt(256);
    }
    return b;
  }

  /// 使用Uri解析网址
  ///  例：Uri uri = Uri.parse(url);
  /// path=https://192.168.0.104/images/app/chat/20231120101757039.mp4?size=100*320
  /// path=/images/app/chat/20231120101757039.mp4
  /// pathSegments=[images, app, chat, 20231120101757039.mp4]
  /// query=size=100*320
  /// queryParameters={size: 100*320}
  /// queryParametersAll={size: [100*320]}
  /// data=null
  /// authority=192.168.0.104
  /// fragment=
  /// userInfo=
  /// scheme=https
  /// port=443
  /// origin=https://192.168.0.104
  static Uri parseUrl(String url) {
    return Uri.parse(url);
  }

  static String bytes2String(List<int> bytes, int start, int end) {
    // A Uint8List is more efficient than a StringBuffer given that we know that
    // we're only emitting ASCII-compatible characters, and that we know the
    // length ahead of time.
    var buffer = Uint8List((end - start) * 2);
    var bufferIndex = 0;

    // A bitwise OR of all bytes in [bytes]. This allows us to check for
    // out-of-range bytes without adding more branches than necessary to the
    // core loop.
    var byteOr = 0;
    for (var i = start; i < end; i++) {
      var byte = bytes[i];
      byteOr |= byte;

      // The bitwise arithmetic here is equivalent to `byte ~/ 16` and `byte % 16`
      // for valid byte values, but is easier for dart2js to optimize given that
      // it can't prove that [byte] will always be positive.
      buffer[bufferIndex++] = _codeUnitForDigit((byte & 0xF0) >> 4);
      buffer[bufferIndex++] = _codeUnitForDigit(byte & 0x0F);
    }

    if (byteOr >= 0 && byteOr <= 255) return String.fromCharCodes(buffer);

    // If there was an invalid byte, find it and throw an exception.
    for (var i = start; i < end; i++) {
      var byte = bytes[i];
      if (byte >= 0 && byte <= 0xff) continue;
      throw FormatException("Invalid byte ${byte < 0 ? "-" : ""}0x${byte.abs().toRadixString(16)}.", bytes, i);
    }

    throw StateError('unreachable');
  }

  static int _codeUnitForDigit(int digit) => digit < 10 ? digit + 0x30 : digit + 0x61 - 10;
}
