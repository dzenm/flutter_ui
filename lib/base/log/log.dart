import 'dart:math';

import 'package:flutter/foundation.dart';

// 缩进的距离
const String interval = '  ';

class Log {
  Log._internal();

  static final Log getInstance = Log._internal();

  static const String _TAG = 'Log';

  static const int _INFO = 4;
  static const int _DEBUG = 5;
  static const int _ERROR = 6;

  static int sLevel = _DEBUG;

  static bool debuggable = true; // 是否是debug模式
  static String sTag = _TAG;
  static const MAX_LENGTH = 800;

  static void init({bool isDebug = true, String tag = _TAG}) {
    debuggable = isDebug;
    sTag = tag;
  }

  static void i(dynamic message, {String tag = ''}) {
    _printLog(tag, 'I', _INFO, message);
  }

  static void d(dynamic message, {String tag = ''}) {
    _printLog(tag, 'D', _DEBUG, message);
  }

  static void e(dynamic message, {String tag = ''}) {
    _printLog(tag, 'E', _ERROR, message);
  }

  static void _printLog(String tag, String stag, int level, dynamic message) {
    if (kReleaseMode) {
      // release模式不打印
      return;
    }
    if (debuggable) {
      if (sLevel <= level) {
        _printLongMsg(level, _handlerMessage(tag, stag, message));
      }
    }
  }

  // 打印长日志
  static void _printLongMsg(int level, dynamic msg) {
    int len = msg.length;
    if (len > MAX_LENGTH) {
      for (int i = 0; i < len;) {
        int start = i;
        i = i + MAX_LENGTH;
        _println(level, msg.substring(start, min(i, len)));
      }
    } else {
      _println(level, msg);
    }
  }

  // 处理消息的内容
  static String _handlerMessage(String tag, String stag, dynamic message) {
    StringBuffer sb = StringBuffer();
    sb.write(DateTime.now());
    sb.write(' ');
    sb.write(stag);
    sb.write('/');
    sb.write((tag.isEmpty) ? sTag : tag);
    sb.write('  ');
    sb.write(message);
    return sb.toString();
  }

  // 换行打印
  static void _println(int level, String message, {bool isDefaultColor = true}) {
    String prefix = _handlerPrefixTextColor(level, isDefaultColor);
    String suffix = _handlerSuffixTextColor(level, isDefaultColor);
    String msg = prefix + message + suffix;
    print(msg);
  }

  // 处理前缀文本颜色
  static String _handlerPrefixTextColor(int level, bool isDefaultColor) {
    if (isDefaultColor) return '';
    switch (level) {
      case _INFO:
        return '\x1B[35m ';
      case _DEBUG:
        return '\x1B[35m ';
      case _ERROR:
        return '\x1B[31m ';
      default:
        return '';
    }
  }

  // 处理后缀文本颜色
  static String _handlerSuffixTextColor(int level, bool isDefaultColor) {
    if (isDefaultColor) return '';
    switch (level) {
      case _INFO:
        return ' \x1B[0m';
      case _DEBUG:
        return ' \x1B[0m';
      case _ERROR:
        return ' \x1B[0m';
      default:
        return '';
    }
  }
}
