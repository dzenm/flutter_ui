

class Log {
  Log._internal();

  static final Log instance = Log._internal();

  static const String _TAG = "Log";

  static const int _INFO = 4;
  static const int _DEBUG = 5;
  static const int _ERROR = 6;

  static int sLevel = _DEBUG;

  static bool debuggable = true; // 是否是debug模式
  static String sTag = _TAG;

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

  static void httpLog(dynamic message, {String tag = ''}) {
    print(message.toString());
  }

  static void _printLog(String tag, String stag, int level, dynamic message) {
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
    print(sb.toString());
  }
}
