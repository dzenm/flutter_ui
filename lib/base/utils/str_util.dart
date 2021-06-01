import 'dart:convert';

/// 字符串工具类
class StrUtil {
  static String strToMap() {
    StringBuffer sb = StringBuffer();

    return sb.toString();
  }

  static String strToList() {
    StringBuffer sb = StringBuffer();

    return sb.toString();
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
