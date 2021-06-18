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
        _print(tag, stag, message);
      }
    }
  }

  static void _print(String tag, String stag, dynamic message) {
    StringBuffer sb = new StringBuffer();
    sb.write(DateTime.now());
    sb.write(' ');
    sb.write(stag);
    sb.write('/');
    sb.write((tag.isEmpty) ? sTag : tag);
    sb.write('  ');
    sb.write(message);
    debugPrint(sb.toString());
  }

  static void _printLongMsg(dynamic msg) {
    int len = msg.length;
    if (len > MAX_LENGTH) {
      for (int i = 0; i < len;) {
        int start = i;
        i = i + MAX_LENGTH;
        print(msg.substring(start, min(i, len)));
      }
    } else {
      print(msg);
    }
  }
}
