/// 创建日志打印
typedef LoggerBuilder = Logger Function(LogManager manager);

///
/// Created by a0010 on 2022/3/22 09:38
/// ╔═══════════════════════════════════════════════════════ [Log] 框架图 ═══════════════════════════════════════════════════════════════╗
/// ║                                                                                   .                                                  ║
/// ║                                          .              [_ConsolePrinter] ←───┐                                                      ║
/// ║                                                                               │                                                      ║
/// ║                    [_Logger] ←─── [_LoggerMixin] ←───┐                        └───┬─── [Logger.printers] ←─── [LogPrinter.output]    ║
/// ║                                                      │                            ├─── [Logger.http]                                 ║
/// ║                 [LogManager] ←───┐                   │                            ├─── [Logger.db]                                   ║
/// ║                                  │                   │                            ├─── [Logger.page]                                 ║
/// ║              ┌─── [Log.init] ←───┴─── [_manager] ←───┼─── [LogManager.logger] ←───┼─── [Logger.verbose]                              ║
/// ║              │                                       │                            ├─── [Logger.debug]                                ║
/// ║              │                                       │                            ├─── [Logger.info]                                 ║
/// ║              │                                       │                            ├─── [Logger.warming]                              ║
/// ║              │                                       │                            └─── [Logger.error]                                ║
/// ║              │                                       │                                                                               ║
/// ║              ├─── [h] ←───┐                          │                                                                               ║
/// ║              ├─── [b] ←───┤                          │                                                                               ║
/// ║              ├─── [p] ←───┤                          │                                                                               ║
/// ║    [Log] ←───┼─── [v] ←───┼──────────────────────────┘                                                                               ║
/// ║              ├─── [d] ←───┤                                                                                                          ║
/// ║              ├─── [i] ←───┤                                                                                                          ║
/// ║              ├─── [w] ←───┤                                                                                                          ║
/// ║              └─── [e] ←───┘                                                                                                          ║
/// ║                                                                                                                                      ║
/// ╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝
/// 日志输出
/// 直接输出
///  Log.d('this is log');
/// 如果需要自定义，请在打印前，调用 [Log.init] 进行设置。
///
/// [Logging] 是可以通过混入在其它类里，然后直接调用日志输出的级别，默认tag为当前混入
/// 的类的类名
///
/// [Logger] 是组装日志信息的结构，[_Logger] 为默认的展示格式，如果对当前展示的格式
/// 不满意，可以进行继承实现，然后通过 [LogManager.builder] 进行构建
///
/// [LogPrinter] 是日志最终处理的结果，[_ConsolePrinter] 是默认的处理方式，如果需
/// 要进行其它处理，可以继承实现，然后通过 [Logger.printers] 进行添加
///
final class Log {
  Log._internal();
  static final Log _instance = Log._internal();
  factory Log() => _instance;

  Log.init({LogManager? manager}) {
    if (manager != null) _manager = manager;
  }

  static LogManager _manager = const LogManager(); // 日志输出管理配置
  static Logger get _log => _manager.logger;    // 日志输出工具
  static void h(dynamic msg, {String? tag}) => _log.http(msg, tag: tag);
  static void b(dynamic msg, {String? tag}) => _log.db(msg, tag: tag);
  static void p(dynamic msg, {String? tag}) => _log.page(msg, tag: tag);
  static void v(dynamic msg, {String? tag}) => _log.verbose(msg, tag: tag);
  static void d(dynamic msg, {String? tag}) => _log.debug(msg, tag: tag);
  static void i(dynamic msg, {String? tag}) => _log.info(msg, tag: tag);
  static void w(dynamic msg, {String? tag}) => _log.warming(msg, tag: tag);
  static void e(dynamic msg, {String? tag}) => _log.error(msg, tag: tag);
}

/// Log with class name
mixin Logging {
  void    logHttp(dynamic msg) => Log.h(msg, tag: _tag);
  void      logDB(dynamic msg) => Log.b(msg, tag: _tag);
  void    logPage(dynamic msg) => Log.p(msg, tag: _tag);
  void logVerbose(dynamic msg) => Log.v(msg, tag: _tag);
  void   logDebug(dynamic msg) => Log.d(msg, tag: _tag);
  void    logInfo(dynamic msg) => Log.i(msg, tag: _tag);
  void logWarning(dynamic msg) => Log.w(msg, tag: _tag);
  void   logError(dynamic msg) => Log.e(msg, tag: _tag);
  String get _tag => '$runtimeType'.replaceAll('_', '').replaceAll('State', '');
}

/// 日志处理的方式
abstract class LogPrinter {
  /// 输出日志
  void output(LogManager manager, String msg, {String head = '', String tail = ''});
}

/// 在控制台输出日志
class _ConsolePrinter extends LogPrinter {
  @override
  void output(LogManager manager, String body, {String head = '', String tail = ''}) {
    LogConfig config = Log._manager.config;
    int limitLength = config.limitLength;
    int chunkLength = config.chunkLength;
    String carriageReturn = config.carriageReturn;

    int index = body.indexOf('\n');
    int size = index == -1 ? body.length : index;
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
  void _print(dynamic object) => print(object);
}

/// 输出日志接口
abstract class Logger {
  LogManager get manager;
  List<LogPrinter> get printers;
  void verbose(dynamic msg, {String? tag});
  void   debug(dynamic msg, {String? tag});
  void    info(dynamic msg, {String? tag});
  void warming(dynamic msg, {String? tag});
  void   error(dynamic msg, {String? tag});
  void    http(dynamic msg, {String? tag});
  void      db(dynamic msg, {String? tag});
  void    page(dynamic msg, {String? tag});
}

/// 组装和输出不同级别[Level]的日志
mixin _LoggerMixin implements Logger {
  void log(dynamic msg, String? tag, Level level) {
    // 判断是否达到需要输出的级别
    if ((manager.level ?? Level.kDebug) & level.flag <= 0) return;

    LogConfig config = manager.config;
    StringBuffer sb = StringBuffer();
    // 基本信息
    sb
      ..write(config.packageName)
      ..write(' [${config.now}] ');
    // 输出调用的位置
    if (config.showCaller) {
      LogCaller? caller = LogCaller.parse(StackTrace.current);
      String result = caller.toString();
      if (caller != null) {
        if (config.isAligned) {
          int len = 40;
          while ((len += 10) < result.length) {}
          result = result.padRight(len);
        }
        sb.write('  $result   ');
      }
    }
    // 输出tag
    sb.write(level.tag);
    String myTag = tag ?? manager.tag;
    if (config.isAligned) {
      int len = config.alignedTagMaxLength;
      if (len < myTag.length) {
        myTag = '${myTag.substring(0, len - 3)}...';
      }
      myTag = myTag.padRight(len);
    }
    sb.write('/$myTag  ');
    sb.write('$msg');

    String body = sb.toString();
    // 给日志增加颜色
    String head = '', tail = '';
    if (config.isColorful) {
      head = '\x1b[${level.color}m '; // 字符变色的前缀
      tail = ' \x1b[0m'; // 字符变色的后缀
    }

    for (var printer in printers) {
      printer.output(manager, body, head: head, tail: tail);
    }
  }
  @override void    http(msg, {tag}) => log(msg, tag, Level.http);
  @override void      db(msg, {tag}) => log(msg, tag, Level.db);
  @override void    page(msg, {tag}) => log(msg, tag, Level.page);
  @override void verbose(msg, {tag}) => log(msg, tag, Level.verbose);
  @override void   debug(msg, {tag}) => log(msg, tag, Level.debug);
  @override void    info(msg, {tag}) => log(msg, tag, Level.info);
  @override void warming(msg, {tag}) => log(msg, tag, Level.warming);
  @override void   error(msg, {tag}) => log(msg, tag, Level.error);
}

/// 输出日志工具
class _Logger with _LoggerMixin {
  final LogManager logManager;
  _Logger({required this.logManager});
  final LogPrinter _printer = _ConsolePrinter();

  @override LogManager get manager => logManager;
  @override List<LogPrinter> get printers => [_printer];
}

/// 日志管理
class LogManager {
  final LoggerBuilder? builder;   // 创建日志输出
  final bool isDebug;             // 是否是debug模式
  final String tag;               // 默认的tag名称
  final LogConfig config;         // 日志的配置信息
  final int? level;               // 可以输出日志的级别，[level] 值只能为 [Level.kDebug]、[Level.kDevelop]、[Level.kRelease]

  const LogManager({
    this.builder,
    this.isDebug = true,
    this.tag = _tag,
    LogConfig? config,
    this.level,
  }) : config = config ?? const LogConfig();
  Logger get logger {
    if (builder == null) return _Logger(logManager: this);
    return builder!(this);
  }
  static const String _tag = 'Log';
}

/// 日志的配置信息
class LogConfig {
  final bool isColorful;          // 是否在输出的日志展示颜色
  final bool isAligned;           // 是否在输出的日志保持对齐
  final bool showCaller;          // 输出的日志展示调用的行数
  final int alignedTagMaxLength;  // 输出的日志Tag最大长度
  final String packageName;       // 输出的包名，为空则不展示
  final String? datePattern;      // 输出时间的格式
  final int chunkLength;          // 日志过长时分块处理日志的长度
  final int limitLength;          // 限制最大的输出长度, -1为不限制
  final String carriageReturn;    // 换行标识 ↩️ ↩  ⏎

  const LogConfig({
    this.isColorful = true,
    this.isAligned = true,
    this.showCaller = false,
    this.alignedTagMaxLength = 16,
    this.packageName = '',
    this.datePattern,
    this.chunkLength = 1000,
    this.limitLength = -1,
    this.carriageReturn = '⏎',
  });

  /// 当前时间字符串：格式为 'yyyy/mm/dd HH:MM:SSS'
  String get now {
    DateTime now = DateTime.now();
    String pattern = datePattern ?? 'yyyy/mm/dd HH:MM:SSS';
    String y = '', m = '', d = '', hou = '', min = '', sec = '', mill = '';
    if (pattern.contains('yyyy')) y = '${now.year}';
    if (pattern.contains('mm')) m = '${now.month}'.padLeft(2, '0');
    if (pattern.contains('dd')) d = '${now.day}'.padLeft(2, '0');
    if (pattern.contains('HH')) hou = '${now.hour}'.padLeft(2, '0');
    if (pattern.contains('MM')) min = '${now.minute}'.padLeft(2, '0');
    if (pattern.contains('mm')) sec = '${now.second}'.padLeft(2, '0');
    if (pattern.contains('SSS')) mill = '${now.millisecond}'.padLeft(3, '0').substring(0, 3);
    return '$y/$m/$d $hou:$min:$sec $mill';
  }
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
      // 当前文件所在的相对位置，跳过不输出
      if (line.contains('base/config/log.dart:')) continue;
      // assert(line.startsWith('#3      '), 'unknown stack trace: $current');
      if (line.startsWith('#')) return line;
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

/// 输出日志的级别
enum Level {
  verbose(1 << 0, 'V', '37'), // 1 << 0 = 1
  http   (1 << 5, 'H', '35'), // 1 << 1 = 2
  db     (1 << 6, 'B', '96'), // 1 << 2 = 4
  page   (1 << 7, 'P', '32'), // 1 << 3 = 8
  debug  (1 << 1, 'D', '94'), // 1 << 4 = 16
  info   (1 << 2, 'I', '36'), // 1 << 5 = 32
  warming(1 << 3, 'W', '93'), // 1 << 6 = 64
  error  (1 << 4, 'E', '31'); // 1 << 7 = 128

  final int flag;
  final String tag;
  final String color;
  const Level(this.flag, this.tag, this.color);
  static int kDebug =   http.flag | db.flag | page.flag | debug.flag | info.flag | warming.flag | error.flag; // 2+4+8+16+32+64+128=254
  static int kDevelop =                                                info.flag | warming.flag | error.flag; //          32+64+128=220
  static int kRelease =                                                            warming.flag | error.flag; //             64+128=192
}
