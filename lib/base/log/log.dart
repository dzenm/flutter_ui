import 'dart:math';

import 'package:flutter/foundation.dart';

import 'build_config.dart';

// 缩进的距离
const String interval = '  ';

///
/// Created by a0010 on 2022/3/22 09:38
/// 日志输出
///
class Log {
  Log._internal();

  static Log _instance = Log._internal();

  static const String _tag = 'Log';

  static const int _error = 6;
  static const int _warm = 5;
  static const int _info = 4;
  static const int _debug = 3;
  static const int _verbose = 2;
  static const _maxLength = 800;

  int _level = _verbose;

  bool _debuggable = true; // 是否是debug模式
  String _myTag = _tag;

  static void init({bool isDebug = true, String tag = _tag}) {
    _instance._debuggable = isDebug;
    _instance._myTag = tag;
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

  static void http(dynamic message, {String tag = ''}) {
    if (BuildConfig.showHTTPLog) {
      _printLog(tag, 'HTTP', _error, message);
    }
  }

  static void db(dynamic message, {String tag = ''}) {
    if (BuildConfig.showDBLog) {
      _printLog(tag, 'DB', _error, message);
    }
  }

  static void _printLog(String tag, String levelTag, int level, dynamic message) {
    if (kReleaseMode) {
      // release模式不打印
      return;
    }
    if (_instance._debuggable) {
      if (_instance._level <= level) {
        dynamic msg = _instance._handlerMessage(tag, levelTag, message);
        _instance._printLongMsg(level, msg);
      }
    }
  }

  /// 打印长日志
  void _printLongMsg(int level, dynamic msg) {
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

  /// 处理消息的内容
  String _handlerMessage(String tag, String levelTag, dynamic message) {
    DateTime now = DateTime.now();
    String year = '${now.year}';
    String month = '${now.month}'.padLeft(2, '0');
    String day = '${now.day}'.padLeft(2, '0');
    String hour = '${now.hour}'.padLeft(2, '0');
    String minute = '${now.minute}'.padLeft(2, '0');
    String second = '${now.second}'.padLeft(2, '0');
    String millisecond = '${now.millisecond}'.padLeft(3, '0').substring(0, 3);
    String time = '$year-$month-$day $hour:$minute:$second $millisecond';

    StringBuffer sb = StringBuffer();
    sb.write(time);
    sb.write(' ');
    sb.write(levelTag);
    sb.write('/');
    sb.write((tag.isEmpty) ? _myTag : tag);
    sb.write('  ');
    sb.write(message);
    return sb.toString();
  }

  /// 换行打印
  void _println(int level, String message, {bool isDefaultColor = true}) {
    String prefix = _handlerPrefixTextColor(level, isDefaultColor);
    String suffix = _handlerSuffixTextColor(level, isDefaultColor);
    String msg = prefix + message + suffix;
    if (kDebugMode) {
      print(msg);
    }
  }

  /// 处理前缀文本颜色
  String _handlerPrefixTextColor(int level, bool isDefaultColor) {
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

  /// 处理后缀文本颜色
  String _handlerSuffixTextColor(int level, bool isDefaultColor) {
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
