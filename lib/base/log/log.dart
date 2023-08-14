import 'dart:math';

import 'package:flutter/foundation.dart';

import 'build_config.dart';

///
/// Created by a0010 on 2022/3/22 09:38
/// 日志打印
///
class Log {
  Log._internal();

  static final Log _instance = Log._internal();

  static Log get instance => _instance;

  factory Log() => _instance;

  static const String _tag = 'Log';
  static const int _maxLength = 800;

  /// 打印日志的级别
  Level _level = Level.verbose;

  /// 是否是debug模式
  bool _debug = true;

  /// 默认打印日志的tag
  String _myTag = _tag;

  static void init({bool isDebug = true, String tag = _tag, Level level = Level.verbose}) {
    _instance._debug = isDebug;
    _instance._myTag = tag;
    _instance._level = level;
  }

  static void v(dynamic message, {String tag = ''}) {
    _printLog(tag, message, Level.verbose);
  }

  static void d(dynamic message, {String tag = ''}) {
    _printLog(tag, message, Level.debug);
  }

  static void i(dynamic message, {String tag = ''}) {
    _printLog(tag, message, Level.info);
  }

  static void w(dynamic message, {String tag = ''}) {
    _printLog(tag, message, Level.warm);
  }

  static void e(dynamic message, {String tag = ''}) {
    _printLog(tag, message, Level.error);
  }

  static void h(dynamic message, {String tag = ''}) {
    if (!BuildConfig.showHTTPLog) return;
    _printLog(tag, message, Level.http);
  }

  static void b(dynamic message, {String tag = ''}) {
    if (!BuildConfig.showDBLog) return;
    _printLog(tag, message, Level.db);
  }

  static void p(dynamic message, {String tag = ''}) {
    if (!BuildConfig.showPageLog || message == null) return;
    _printLog(tag, message, Level.page);
  }

  static void _printLog(String tag, dynamic message, Level level) {
    if (kReleaseMode) {
      // release模式不打印
      return;
    }
    if (!_instance._debug) {
      // 如果不是自定义的debug模式也不打印
      return;
    }
    if (_instance._level.value > level.value) {
      // 如果打印的日志级别在默认的级别之下不打印
      return;
    }
    String result = _instance._handlerMessage(tag, level.tag, message);
    _instance._printLongMsg(result, (msg) => _instance._println(level, msg));
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

  /// 打印长日志
  void _printLongMsg(String message, void Function(String message) printLog) {
    int len = message.length;
    if (len > _maxLength) {
      for (int i = 0; i < len;) {
        int start = i;
        i = i + _maxLength;
        printLog(message.substring(start, min(i, len)));
      }
    } else {
      printLog(message);
    }
  }

  /// 换行打印
  void _println(Level level, String message, {bool isDefaultColor = true}) {
    // 处理文本展示的颜色
    String prefix = '', suffix = '';
    if (!isDefaultColor) {
      List<String> colors = _handlerPrefixTextColor(level);
      prefix = colors[0];
      suffix = colors[1];
    }
    String msg = prefix + message + suffix;
    if (kDebugMode) {
      print(msg);
    }
  }

  /// 处理文本颜色
  List<String> _handlerPrefixTextColor(Level level) {
    switch (level) {
      case Level.verbose:
        return ['\x1B[35m ', ' \x1B[0m'];
      case Level.debug:
        return ['\x1B[35m ', ' \x1B[0m'];
      case Level.info:
        return ['\x1B[35m ', ' \x1B[0m'];
      case Level.warm:
        return ['\x1B[35m ', ' \x1B[0m'];
      case Level.error:
        return ['\x1B[31m ', ' \x1B[0m'];
      default:
        return ['', ''];
    }
  }
}

/// 打印日志的级别
enum Level {
  verbose(2, 'V'),
  debug(3, 'D'),
  info(4, 'I'),
  warm(5, 'W'),
  error(6, 'E'),
  http(7, 'H'),
  db(8, 'B'),
  page(9, 'P');

  final int value;
  final String tag;

  const Level(this.value, this.tag);
}
