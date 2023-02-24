import 'dart:math';

import 'package:flutter/foundation.dart';

// 缩进的距离
const String interval = '  ';

///
/// Created by a0010 on 2022/3/22 09:38
/// 日志输出
///
class Log {
  Log._internal();

  static final Log instance = Log._internal();

  static const String _tag = 'Log';

  static const int _error = 6;
  static const int _warm = 5;
  static const int _info = 4;
  static const int _debug = 3;
  static const int _verbose = 2;
  static const _maxLength = 800;

  static int sLevel = _verbose;

  static bool debuggable = true; // 是否是debug模式
  static String sTag = _tag;

  static void init({bool isDebug = true, String tag = _tag}) {
    debuggable = isDebug;
    sTag = tag;
  }

  static void v(dynamic message, {String tag = ''}) {
    _printLog(tag, 'V', _verbose, message);
  }

  static void d(dynamic message, {String tag = ''}) {
    _printLog(tag, 'D', _debug, message);
  }

  static void i(dynamic message, {String tag = ''}) {
    _printLog(tag, 'I', _info, message);
  }

  static void w(dynamic message, {String tag = ''}) {
    _printLog(tag, 'W', _warm, message);
  }

  static void e(dynamic message, {String tag = ''}) {
    _printLog(tag, 'E', _error, message);
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
    if (len > _maxLength) {
      for (int i = 0; i < len;) {
        int start = i;
        i = i + _maxLength;
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
    if (kDebugMode) {
      print(msg);
    }
  }

  // 处理前缀文本颜色
  static String _handlerPrefixTextColor(int level, bool isDefaultColor) {
    if (isDefaultColor) return '';
    switch (level) {
      case _verbose:
        return '\x1B[35m ';
      case _debug:
        return '\x1B[35m ';
      case _info:
        return '\x1B[35m ';
      case _warm:
        return '\x1B[35m ';
      case _error:
        return '\x1B[31m ';
      default:
        return '';
    }
  }

  // 处理后缀文本颜色
  static String _handlerSuffixTextColor(int level, bool isDefaultColor) {
    if (isDefaultColor) return '';
    switch (level) {
      case _verbose:
        return ' \x1B[0m';
      case _debug:
        return ' \x1B[0m';
      case _info:
        return ' \x1B[0m';
      case _warm:
        return ' \x1B[0m';
      case _error:
        return ' \x1B[0m';
      default:
        return '';
    }
  }
}
