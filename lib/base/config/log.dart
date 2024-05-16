import 'build_config.dart';

///
/// Created by a0010 on 2022/3/22 09:38
/// 日志打印
///
final class Log {
  Log._internal();
  static final Log _ins = Log._internal();
  factory Log() => _ins;

  static const String _tag = 'Log';

  static void init({LogConfig? config}) {
    _ins._config = config;
  }

  LogConfig? _config; // 日志输出的配置信息
  final _Logger _log = _Logger();
  static void v(dynamic msg, {String? tag}) => _ins._log.verbose(msg, tag: tag);
  static void d(dynamic msg, {String? tag}) => _ins._log.debug(msg, tag: tag);
  static void i(dynamic msg, {String? tag}) => _ins._log.info(msg, tag: tag);
  static void w(dynamic msg, {String? tag}) => _ins._log.warning(msg, tag: tag);
  static void e(dynamic msg, {String? tag}) => _ins._log.error(msg, tag: tag);
  static void h(dynamic msg, {String? tag}) => _ins._log.http(msg, tag: tag);
  static void b(dynamic msg, {String? tag}) => _ins._log.db(msg, tag: tag);
  static void p(dynamic msg, {String? tag}) => _ins._log.page(msg, tag: tag);
}

/// Log with class name
mixin Logging {
  void logVerbose(String msg) => Log.v(msg, tag: _tag);
  void   logDebug(String msg) => Log.d(msg, tag: _tag);
  void    logInfo(String msg) => Log.i(msg, tag: _tag);
  void logWarning(String msg) => Log.w(msg, tag: _tag);
  void   logError(String msg) => Log.e(msg, tag: _tag);
  void    logHttp(String msg) => Log.h(msg, tag: _tag);
  void      logDB(String msg) => Log.b(msg, tag: _tag);
  void    logPage(String msg) => Log.p(msg, tag: _tag);
  String get _tag => '$runtimeType';
}

/// 日志输出的内容格式
abstract class LogPrinter {
  /// 输出日志
  void output(String msg, {String head = '', String tail = ''});
}

/// 默认日志输出方式
class _LogPrinter extends LogPrinter {
  int chunkLength = 1000; // split output when it's too long
  int limitLength = -1; // max output length, -1 means unlimited

  String carriageReturn = '↩️';

  @override
  void output(String body, {String head = '', String tail = ''}) {
    int size = body.length;
    if (0 < limitLength && limitLength < size) {
      body = '${body.substring(0, limitLength - 3)}...';
      size = limitLength;
    }
    int start = 0, end = chunkLength;
    for (; end <= size; start = end, end += chunkLength) {
      _print(head + body.substring(start, end) + tail + carriageReturn);
    }
    if (start >= size) {
      // all chunks printed
      assert(start == size, 'should not happen');
    } else if (start == 0) {
      // body too short
      _print(head + body + tail);
    } else {
      // print last chunk
      _print(head + body.substring(start) + tail);
    }
  }

  /// override for redirecting outputs
  void _print(Object? object) => print(object);
}

/// 输出日志接口
abstract class Logger {
  List<LogPrinter> get printers;
  void verbose(dynamic msg, {String? tag});
  void   debug(dynamic msg, {String? tag});
  void    info(dynamic msg, {String? tag});
  void warning(dynamic msg, {String? tag});
  void   error(dynamic msg, {String? tag});
  void    http(dynamic msg, {String? tag});
  void      db(dynamic msg, {String? tag});
  void    page(dynamic msg, {String? tag});
}

/// 组装和输出不同级别[Level]的日志
mixin _LoggerMixin implements Logger {
  /// 当前时间字符串：格式为 'yyyy/mm/dd HH:MM:SSS'
  String get now {
    DateTime now = DateTime.now();
    String m = '${now.month}'.padLeft(2, '0');
    String d = '${now.day}'.padLeft(2, '0');
    String h = '${now.hour}'.padLeft(2, '0');
    String min = '${now.minute}'.padLeft(2, '0');
    String sec = '${now.second}'.padLeft(2, '0');
    String mill = '${now.millisecond}'.padLeft(3, '0').substring(0, 3);
    return '${now.year}/$m/$d $h:$min:$sec $mill';
  }

  /// 日志输出的配置信息
  LogConfig get _config => Log._ins._config ?? LogConfig();

  void log(Level level, dynamic msg, String? tag) {
    // 判断是否达到需要打印的级别
    if (_config.level & level.flag <= 0) return;

    String packageName = BuildConfig.isInitialized ? BuildConfig.packageInfo.packageName : '';
    StringBuffer sb = StringBuffer();
    sb
      ..write(packageName)
      ..write(' [$now] ')
      ..write(level.tag);
    String myTag = tag ?? Log._tag;
    if (_config.aligned) {
      int len = _config.alignedTagMaxLength;
      if (len < myTag.length) {
        myTag = '${myTag.substring(0, len - 3)}...';
      }
      myTag = myTag.padRight(len);
    }
    sb.write('/$myTag  ');
    if (_config.showCaller) {
      LogCaller? caller = LogCaller.parse(StackTrace.current);
      if (caller != null) {
        sb.write('$caller $msg');
      } else {
        sb.write(msg);
      }
    } else {
      sb.write(msg);
    }

    String body = sb.toString();
    if (_config.colorful) {
      // 字符变色的前缀
      String head = '\x1b[${level.color}m ';
      // 字符变色的后缀
      String tail = ' \x1b[0m';
      for (var printer in printers) {
        printer.output(body, head: head, tail: tail);
      }
    } else {
      for (var printer in printers) {
        printer.output(body);
      }
    }
  }

  @override
  void verbose(msg, {tag}) => log(Level.verbose, msg, tag);
  @override
  void   debug(msg, {tag}) => log(Level.debug, msg, tag);
  @override
  void    info(msg, {tag}) => log(Level.info, msg, tag);
  @override
  void warning(msg, {tag}) => log(Level.warning, msg, tag);
  @override
  void   error(msg, {tag}) => log(Level.error, msg, tag);
  @override
  void    http(msg, {tag}) => log(Level.http, msg, tag);
  @override
  void      db(msg, {tag}) => log(Level.db, msg, tag);
  @override
  void    page(msg, {tag}) => log(Level.page, msg, tag);
}

/// 输出日志
class _Logger with _LoggerMixin {
  final LogPrinter _printer = _LogPrinter();

  @override
  List<LogPrinter> get printers => [_printer];
}

/// 输出调用所在的行数
class LogCaller {
  LogCaller(this.name, this.path, this.line);

  final String name;
  final String path;
  final int line;

  @override
  String toString() => '$path:$line';

  /// locate the real caller: '#3      ...'
  static String? locate(StackTrace current) {
    List<String> array = current.toString().split('\n');
    for (String line in array) {
      if (line.contains('base/config/log.dart:')) {
        // skip for Log
        continue;
      }
      // assert(line.startsWith('#3      '), 'unknown stack trace: $current');
      if (line.startsWith('#')) {
        return line;
      }
    }
    // unknown format
    return null;
  }

  /// parse caller info from trace
  static LogCaller? parse(StackTrace current) {
    String? text = locate(current);
    if (text == null) {
      // unknown format
      return null;
    }
    // skip '#0      '
    int pos = text.indexOf(' ');
    text = text.substring(pos + 1).trimLeft();
    // split 'name' & '(path:line:column)'
    pos = text.lastIndexOf(' ');
    String name = text.substring(0, pos);
    String tail = text.substring(pos + 1);
    String path = 'unknown.file';
    String line = '-1';
    int pos1 = tail.indexOf(':');
    if (pos1 > 0) {
      pos = tail.indexOf(':', pos1 + 1);
      if (pos > 0) {
        path = tail.substring(1, pos);
        pos1 = pos + 1;
        pos = tail.indexOf(':', pos1);
        if (pos > 0) {
          line = tail.substring(pos1, pos);
        } else if (pos1 < tail.length) {
          line = tail.substring(pos1, tail.length - 1);
        }
      }
    }
    return LogCaller(name, path, int.parse(line));
  }
}

/// 日志的配置信息
class LogConfig {
  int level;                // 可以打印日志的级别，[level] 值只能为 [Level.kDebug]、[Level.kDevelop]、[Level.kRelease]
  bool colorful;            // 输出的日志展示颜色
  bool aligned;             // 输出的日志对齐
  int alignedTagMaxLength;  // 输出的日志Tag最大长度
  bool showCaller;          // 输出的日志展示调用的行数
  LogConfig({
    int? level,
    this.colorful = true,
    this.aligned = true,
    this.alignedTagMaxLength = 16,
    this.showCaller = false
  }) : level = level ?? Level.kDebug;
}

/// 输出日志的级别
enum Level {
  verbose(1 << 0, 'V', '37'), // 1 << 0 = 1
  debug  (1 << 1, 'D', '94'), // 1 << 1 = 2
  info   (1 << 2, 'I', '36'), // 1 << 2 = 4
  warning(1 << 3, 'W', '93'), // 1 << 3 = 8
  error  (1 << 4, 'E', '31'), // 1 << 4 = 16
  http   (1 << 5, 'H', '35'), // 1 << 5 = 32
  db     (1 << 6, 'B', '96'), // 1 << 6 = 64
  page   (1 << 7, 'P', '32'); // 1 << 7 = 128

  final int flag;
  final String tag;
  final String color;

  const Level(this.flag, this.tag, this.color);

  static int kDebug =   debug.flag | info.flag | warning.flag | error.flag | http.flag | db.flag | page.flag; // 2+4+8+16+32+64+128=254
  static int kDevelop =              info.flag | warning.flag | error.flag | http.flag | db.flag | page.flag; //   4+8+16+32+64+128=252
  static int kRelease =                          warning.flag | error.flag;                                   //     8+16          =24
}
