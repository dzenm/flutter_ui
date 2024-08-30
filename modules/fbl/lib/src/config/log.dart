/// 创建日志打印
typedef LoggerBuilder = Logger Function(LogManager manager);

///
/// Created by a0010 on 2022/3/22 09:38
/// ╔═══════════════════════════════════════════════════════ [Log] 框架图 ═══════════════════════════════════════════════════════════════╗
/// ║                                                                                   .                                                  ║
/// ║                                          .       [_DefaultConsolePrinter] ←───┐                                                      ║
/// ║                                                                               │                                                      ║
/// ║               [DefaultLogger] ←─── [LoggerMixin] ←───┐                        └───┬─── [Logger.printers] ←─── [LogPrinter.output]    ║
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
/// [Logger] 是组装日志信息的结构，[DefaultLogger] 为默认的展示格式，如果对当前展示的格式
/// 不满意，可以进行继承实现，然后通过 [LogManager.builder] 进行构建
///
/// [LogPrinter] 是日志最终处理的结果，[_DefaultConsolePrinter] 是默认的处理方式，如果需
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
  static Logger get _log => _manager.logger; // 日志输出工具
  static void v(Object? msg, {String? tag}) => _log.verbose(msg, tag: tag);
  static void h(Object? msg, {String? tag}) => _log.http(msg, tag: tag);
  static void b(Object? msg, {String? tag}) => _log.db(msg, tag: tag);
  static void p(Object? msg, {String? tag}) => _log.page(msg, tag: tag);
  static void d(Object? msg, {String? tag}) => _log.debug(msg, tag: tag);
  static void i(Object? msg, {String? tag}) => _log.info(msg, tag: tag);
  static void w(Object? msg, {String? tag}) => _log.warming(msg, tag: tag);
  static void e(Object? msg, {String? tag}) => _log.error(msg, tag: tag);
}

/// Log with class name
mixin Logging {
  void logVerbose(Object? msg) => Log.v(msg, tag: _tag);
  void logHttp(Object? msg) => Log.h(msg, tag: _tag);
  void logDB(Object? msg) => Log.b(msg, tag: _tag);
  void logPage(Object? msg) => Log.p(msg, tag: _tag);
  void logDebug(Object? msg) => Log.d(msg, tag: _tag);
  void logInfo(Object? msg) => Log.i(msg, tag: _tag);
  void logWarning(Object? msg) => Log.w(msg, tag: _tag);
  void logError(Object? msg) => Log.e(msg, tag: _tag);
  String get _tag => '$runtimeType'.replaceAll('_', '').replaceAll('State', '');
}

/// 日志处理的方式
abstract class LogPrinter {
  /// 输出日志
  void output(
    LogManager manager,
    String title,
    String body, {
    String head = '',
    String tail = '',
  });
}

/// 在控制台输出日志
class _DefaultConsolePrinter extends LogPrinter {
  @override
  void output(
    LogManager manager,
    String title,
    String body, {
    String head = '',
    String tail = '',
  }) {
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
      _print(title + head + body.substring(start, end) + carriageReturn + tail);
    }
    if (start >= size) {
      // all chunks printed
      assert(start == size, 'should not happen');
    } else if (start == 0) {
      // body too short
      _print(title + head + body + tail);
    } else {
      // print last chunk
      _print(title + head + body.substring(start) + tail);
    }
  }
  /// override for redirecting outputs
  void _print(dynamic object) => print(object);
}

/// 输出日志接口
abstract class Logger {
  LogManager get manager;
  List<LogPrinter> get printers;
  void verbose(Object? msg, {String? tag});
  void    http(Object? msg, {String? tag});
  void      db(Object? msg, {String? tag});
  void    page(Object? msg, {String? tag});
  void   debug(Object? msg, {String? tag});
  void    info(Object? msg, {String? tag});
  void warming(Object? msg, {String? tag});
  void   error(Object? msg, {String? tag});
}

/// 组装和输出不同级别[Level]的日志
mixin LoggerMixin implements Logger {
  static String colorRedLight = '31m';
  static String colorRedDark = '91m';
  static String colorGreenLight = '32m';
  static String colorGreenDark = '92m';
  static String colorYellowLight = '33m';
  static String colorYellowDark = '93m';
  static String colorBlueLight = '34m';
  static String colorBlueDark = '94m';
  static String colorMagentaLight = '35m';
  static String colorMagentaDark = '95m';
  static String colorCyanLight = '36m';
  static String colorCyanDark = '96m';
  static String colorWhiteLight = '37m';
  static String colorWhiteDark = '97m';
  static String colorGreyDark = '99m';
  static String colorStart = '\x1B[';
  static String colorClear = '\x1B[0m';

  int get _level => manager.level.value;

  int output(Object? msg, {String? level, String? tag, String color = ''}) {
    LogConfig config = manager.config;

    // 给日志增加颜色
    String head = '', tail = '';
    if (config.isColorful && color.isNotEmpty) {
      head = '$colorStart$color '; // 字符变色的前缀
      tail = ' $colorClear'; // 字符变色的后缀
    }

    String? now = config.showTime ? ' ${config.now}': '';
    StringBuffer sb = StringBuffer();
    // 基本信息
    sb..write(config.packageName)
      ..write(now);
    // 输出调用的位置
    if (config.showCaller) {
      LogCaller? myCaller = LogCaller.parse(StackTrace.current);
      if (myCaller != null) {
        sb.write('   $myCaller   ');
      }
    }
    // 输出tag
    String myTag = tag ?? manager.tag;
    if (config.isAligned) {
      int len = config.alignedTagMaxLength;
      if (len < myTag.length) {
        myTag = '${myTag.substring(0, len - 3)}...';
      }
      myTag = myTag.padRight(len);
    }
    sb.write(' $head$myTag$tail ');
    // 输出Level
    if (config.isColorful && color.isNotEmpty) {
      String? colorful = color.replaceFirst('3', '4').replaceFirst('9', '10');
      sb.write('\x1B[1;37;$colorful${level ?? ''}$colorClear');
    }
    String title = sb.toString();
    String body = msg.toString();
    for (var printer in printers) {
      printer.output(manager, title, body, head: head, tail: tail);
    }
    return body.length;
  }

  @override
  void verbose(Object? msg, {String? tag}) => (_level & LogManager._kVerboseFlag) > 0 &&
      output(msg, level: 'VERBOSE', tag: tag, color: colorWhiteLight) > 0;
  @override
  void http(Object? msg, {String? tag}) => (_level & LogManager._kVerboseFlag) > 0 &&
      output(msg, level: ' HTTP  ', tag: tag, color: colorMagentaLight) > 0;
  @override
  void db(Object? msg, {String? tag}) => (_level & LogManager._kVerboseFlag) > 0 &&
      output(msg, level: '  DB   ', tag: tag, color: colorCyanDark) > 0;
  @override
  void page(Object? msg, {String? tag}) => (_level & LogManager._kVerboseFlag) > 0 &&
      output(msg, level: ' PAGE  ', tag: tag, color: colorGreenLight) > 0;
  @override
  void debug(Object? msg, {String? tag}) => (_level & LogManager._kDebug) > 0 &&
      output(msg, level: ' DEBUG ', tag: tag, color: colorBlueDark) > 0;
  @override
  void info(Object? msg, {String? tag}) => (_level & LogManager._kInfoFlag) > 0 &&
      output(msg, level: ' INFO  ', tag: tag, color: colorCyanLight) > 0;
  @override
  void warming(Object? msg, {String? tag}) => (_level & LogManager._kWarningFlag) > 0 &&
      output(msg, level: 'WARMING', tag: tag, color: colorYellowDark) > 0;
  @override
  void error(Object? msg, {String? tag}) => (_level & LogManager._kErrorFlag) > 0 &&
      output(msg, level: ' ERROR ', tag: tag, color: colorRedLight) > 0;
}

/// 输出日志工具
class DefaultLogger with LoggerMixin {
  final LogManager logManager;
  final List<LogPrinter> logPrinters;
  DefaultLogger({
    required this.logManager,
    List<LogPrinter>? logPrinters,
  }) : logPrinters = [
      _DefaultConsolePrinter(),
      ...logPrinters ?? []
    ];
  @override
  LogManager get manager => logManager;
  @override
  List<LogPrinter> get printers => logPrinters;
}

/// 日志管理
class LogManager {
  static const int _kVerboseFlag = 1 << 3;
  static const int _kDebugFlag   = 1 << 4;
  static const int _kInfoFlag    = 1 << 5;
  static const int _kWarningFlag = 1 << 6;
  static const int _kErrorFlag   = 1 << 7;

  static const int _kDebug   = _kVerboseFlag|_kDebugFlag|_kInfoFlag|_kWarningFlag|_kErrorFlag;
  static const int _kDevelop =                           _kInfoFlag|_kWarningFlag|_kErrorFlag;
  static const int _kRelease =                                      _kWarningFlag|_kErrorFlag;

  final LoggerBuilder? builder; // 创建日志输出
  final bool isDebug; // 是否是打印日志模式
  final String tag; // 默认的tag名称
  final Level level; // 可以输出日志的级别
  final LogConfig config; // 日志的配置信息
  const LogManager({
    this.builder,
    this.isDebug = true,
    this.tag = _tag,
    this.level = Level.debug,
    LogConfig? config,
  }) : config = config ?? const LogConfig();

  Logger get logger => builder == null
      ? DefaultLogger(logManager: this)
      : builder!(this);
  static const String _tag = 'Log';
}

/// 日志的配置信息
class LogConfig {
  final bool isColorful; // 是否在输出的日志展示颜色
  final bool isAligned; // 是否在输出的日志保持对齐
  final bool showCaller; // 输出的日志是否展示调用的行数
  final bool showTime; // 输出的日志是否展示打印的时间
  final int alignedTagMaxLength; // 输出的日志Tag最大长度
  final String packageName; // 输出的包名，为空则不展示
  final int chunkLength; // 日志过长时分块处理日志的长度
  final int limitLength; // 限制最大的输出长度, -1为不限制
  final String carriageReturn; // 换行标识 ↩️ ↩  ⏎

  const LogConfig({
    this.isColorful = true,
    this.isAligned = true,
    this.showCaller = false,
    this.showTime = true,
    this.alignedTagMaxLength = 24,
    this.packageName = '',
    this.chunkLength = 1000,
    this.limitLength = -1,
    this.carriageReturn = '⏎',
  });

  /// full string for current time: 'yyyy-mm-dd HH:MM:SS'
  String get now {
    DateTime time = DateTime.now();
    String m = _twoDigits(time.month);
    String d = _twoDigits(time.day);
    String h = _twoDigits(time.hour);
    String min = _twoDigits(time.minute);
    String sec = _twoDigits(time.second);
    return '${time.year}-$m-$d $h:$min:$sec';
  }
  String _twoDigits(int n) => n >= 10  ? '$n' : '0$n';
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
      if (line.contains('fbl/src/config/log.dart:')) {
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

/// 输出日志的级别
enum Level {
  debug(LogManager._kDebug),
  develop(LogManager._kDevelop),
  release(LogManager._kRelease);
  final int value;
  const Level(this.value);
}