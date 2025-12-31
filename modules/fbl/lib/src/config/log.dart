import 'dart:math';

/// 创建日志打印
typedef LoggerBuilder = Logger Function(LogManager manager);

///
/// Created by a0010 on 2022/3/22 09:38
/// ╔═══════════════════════════════════════════════════════ [Log] 框架图 ═══════════════════════════════════════════════════════════════╗
/// ║                                                                                   .                                                  ║
/// ║                                          .       [_DefaultConsolePrinter] ←───┐                                                      ║
/// ║                                                                               │                                                      ║
/// ║              [_DefaultLogger] ←─── [LoggerMixin] ←───┐                        └───┬─── [Logger.printers] ←─── [LogPrinter.output]    ║
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
///  Log.d("this is log");
/// 如果需要自定义，请在打印前，调用 [Log.init] 进行设置。
///
/// [Logging] 是可以通过混入在其它类里，然后直接调用日志输出的级别，默认tag为当前混入
/// 的类的类名
///
/// [Logger] 是组装日志信息的结构，[_DefaultLogger] 为默认的展示格式，如果对当前展示的格式
/// 不满意，可以进行继承实现，然后通过 [LogManager.builder] 进行构建
///
/// [LogPrinter] 是日志最终处理的结果，[_DefaultConsolePrinter] 是默认的处理方式，如果需
/// 要进行其它处理，可以继承实现，然后通过 [Logger.printers] 进行添加
///
final class Log {
  Log.init({LogManager? manager}) {
    if (manager != null) {
      _manager = manager;
    }
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
  void logHttp(Object? msg)    => Log.h(msg, tag: _tag);
  void logDB(Object? msg)      => Log.b(msg, tag: _tag);
  void logPage(Object? msg)    => Log.p(msg, tag: _tag);
  void logDebug(Object? msg)   => Log.d(msg, tag: _tag);
  void logInfo(Object? msg)    => Log.i(msg, tag: _tag);
  void logWarning(Object? msg) => Log.w(msg, tag: _tag);
  void logError(Object? msg)   => Log.e(msg, tag: _tag);
  String get _tag => "$runtimeType".replaceAll("_", "").replaceAll("State", "");
}

/// 日志处理的方式
abstract class LogPrinter {
  /// 输出日志
  void output(
    LogManager manager,
    String title,
    String titleReplaceBlank,
    String body, {
    String head = "",
    String tail = "",
  });
}

/// 在控制台输出日志
class _DefaultConsolePrinter extends LogPrinter {
  @override
  void output(
    LogManager manager,
    String title,
    String titleReplaceBlank,
    String body, {
    String head = "",
    String tail = "",
  }) {
    LogConfig config = manager.config;
    int chunkLength = config.chunkLength;

    List<String> list = body.split("\n");
    int index = 0;
    for (var item in list) {
      int start = 0, end = 0;
      int len = item.length;
      while (end < len) {
        start = end;
        end = min(start + chunkLength, len);
        // first line print title, others line print blank
        String prefix = index++ == 0 ? title : titleReplaceBlank;
        String text = item.substring(start, end);
        String message = prefix + head + text + tail;
        _print(message);
      }
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
  static const String colorRedLight     = "31m";
  static const String colorRedDark      = "91m";
  static const String colorGreenLight   = "32m";
  static const String colorGreenDark    = "92m";
  static const String colorYellowLight  = "33m";
  static const String colorYellowDark   = "93m";
  static const String colorBlueLight    = "34m";
  static const String colorBlueDark     = "94m";
  static const String colorMagentaLight = "35m";
  static const String colorMagentaDark  = "95m";
  static const String colorCyanLight    = "36m";
  static const String colorCyanDark     = "96m";
  static const String colorWhiteLight   = "37m";
  static const String colorWhiteDark    = "97m";
  static const String colorGreyDark     = "99m";
  static const String colorStart        = "\x1B[";
  static const String colorClear        = "\x1B[0m";
  static const String colorForeground   = "\x1B[1;37;";

  /// 2025-12-31 13:32:08 478 ConversationInit           DEBUG
  int output(Object? msg, String? tag, MessageLevel messageLevel) {
    int level =  manager.level.value;
    if ((level & LogManager._kErrorFlag) <= 0) return 0;

    String levelText = messageLevel.text;
    String textColor = messageLevel.color;
    LogConfig config = manager.config;

    // 为文本展示增加颜色
    String colorPrefix = "", colorSuffix = "";
    String colorPrefixWithForeground = "", colorSuffixWithForeground = "";
    if (config.isColorful) {
      colorPrefix = "$colorStart$textColor"; // 字符变色的前缀
      colorSuffix = " $colorClear"; // 字符变色的后缀
      String? boldColor = textColor.replaceFirst("3", "4").replaceFirst("9", "10");
      colorPrefixWithForeground = "$colorForeground$boldColor";
      colorSuffixWithForeground = " $colorClear";
    }

    String title = "", titleReplaceBlank = "";
    if (!config.showOnlyMessage) {
      // 输出包名
      String packageName = config.packageName;
      String myPackageName = packageName.isEmpty ? "" : "$packageName ";
      // 输出时间
      String time = config.now;
      String myTime = time.isEmpty ? "" : "$time ";
      // 输出调用的位置
      String myCaller = "";
      if (config.showCaller) {
        LogCaller? caller = LogCaller.parse(StackTrace.current);
        if (caller != null) {
          myCaller = "   $caller    ";
        }
      }
      // 输出tag
      String oTag = tag ?? "";
      String showTag = oTag.isEmpty ? manager.tag : oTag;
      int tagMaxLength = config.alignedTagMaxLength;
      String myTag = tagMaxLength < showTag.length
          ? "${showTag.substring(0, tagMaxLength - 2)}.." // 过长截取
          : showTag.padRight(tagMaxLength); // 不足补空
      // 输出level
      String myLevel = levelText;

      // 基本信息
      StringBuffer sb = StringBuffer()
        ..write(myPackageName)
        ..write(myTime)
        ..write(myCaller)
        ..write("$colorPrefix$myTag$colorSuffix")
        ..write("$colorPrefixWithForeground$myLevel$colorSuffixWithForeground ");

      // 获取展示的标题文本长度
      int length = myPackageName.length + myTime.length + myCaller.length + myTag.length + myLevel.length + 3;
      StringBuffer blank = StringBuffer();
      while (length-- > 0) {
        blank.write(" ");
      }

      title = sb.toString();
      titleReplaceBlank = blank.toString();
    }

    String body = msg.toString();
    for (var printer in printers) {
      printer.output(manager, title, titleReplaceBlank, body, head: colorPrefix, tail: colorSuffix);
    }
    return body.length;
  }

  @override
  void verbose(Object? msg, {String? tag}) => output(msg, tag, MessageLevel.verbose);
  @override
  void http   (Object? msg, {String? tag}) => output(msg, tag, MessageLevel.http);
  @override
  void db     (Object? msg, {String? tag}) => output(msg, tag, MessageLevel.db);
  @override
  void page   (Object? msg, {String? tag}) => output(msg, tag, MessageLevel.page);
  @override
  void debug  (Object? msg, {String? tag}) => output(msg, tag, MessageLevel.debug);
  @override
  void info   (Object? msg, {String? tag}) => output(msg, tag, MessageLevel.info);
  @override
  void warming(Object? msg, {String? tag}) => output(msg, tag, MessageLevel.warming);
  @override
  void error  (Object? msg, {String? tag}) => output(msg, tag, MessageLevel.error);
}

/// 输出日志工具
class _DefaultLogger with LoggerMixin {
  _DefaultLogger({
    required LogManager logManager,
    List<LogPrinter> logPrinters = const [],
  })  : _manager = logManager,
        _printers = [_DefaultConsolePrinter(), ...logPrinters];

  @override
  LogManager get manager => _manager;
  final LogManager _manager;
  @override
  List<LogPrinter> get printers => _printers;
  final List<LogPrinter> _printers;
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
    Level level = Level.release,
    LogConfig? config,
  }) : level = isDebug ? Level.debug : level,
       config = config ?? const LogConfig();

  Logger get logger => builder == null ? _DefaultLogger(logManager: this) : builder!(this);
  static const String _tag = "Log";
}

/// 日志的配置信息
class LogConfig {
  final bool isColorful; // 是否在输出的日志展示颜色
  final bool showCaller; // 输出的日志是否展示调用的行数
  final bool showTime; // 输出的日志是否展示打印的时间
  final bool showOnlyMessage; // 输出的日志是否只展示打印的信息
  final int alignedTagMaxLength; // 输出的日志Tag最大长度
  final String packageName; // 输出的包名，为空则不展示
  final int chunkLength; // 日志过长时分块处理日志的长度

  const LogConfig({
    this.isColorful = true,
    this.showCaller = false,
    this.showTime = true,
    this.showOnlyMessage = false,
    this.alignedTagMaxLength = 24,
    this.packageName = "",
    this.chunkLength = 300,
  });

  /// full string for current time: "yyyy-mm-dd HH:MM:ss SSS"
  String get now {
    if (!showTime) return "";
    DateTime d = DateTime.now();
    String t(int val) => val > 9 ? "$val" : "0$val";
    return " ${d.year}-${t(d.month)}-${t(d.day)} "
        "${t(d.hour)}:${t(d.minute)}:${t(d.second)} "
        "${d.millisecond.toString().padLeft(3, "0")}";
  }
}

/// 输出调用所在的行数
class LogCaller {
  final String name;
  final String path;
  final int line;

  LogCaller(this.name, this.path, this.line);

  @override
  String toString() => "$path:$line";

  /// locate the real caller: "#3      ..."
  static String? locate(StackTrace current) {
    List<String> array = current.toString().split("\n");
    for (String line in array) {
      if (line.contains("fbl/src/config/log.dart:")) {
        // skip for Log
        continue;
      }
      // assert(line.startsWith("#3      "), "unknown stack trace: $current");
      if (line.startsWith("#")) {
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
    // skip "#0      "
    int pos = text.indexOf(" ");
    text = text.substring(pos + 1).trimLeft();
    // split "name" & "(path:line:column)"
    pos = text.lastIndexOf(" ");
    String name = text.substring(0, pos);
    String tail = text.substring(pos + 1);
    String path = "unknown.file";
    String line = "-1";
    int pos1 = tail.indexOf(":");
    if (pos1 > 0) {
      pos = tail.indexOf(":", pos1 + 1);
      if (pos > 0) {
        path = tail.substring(1, pos);
        pos1 = pos + 1;
        pos = tail.indexOf(":", pos1);
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

/// 输出的消息级别
enum MessageLevel {
  verbose(LogManager._kVerboseFlag, "VERBOSE", LoggerMixin.colorWhiteLight),
  http   (LogManager._kVerboseFlag, " HTTP  ", LoggerMixin.colorMagentaLight),
  db     (LogManager._kVerboseFlag, "  DB   ", LoggerMixin.colorCyanDark),
  page   (LogManager._kVerboseFlag, " PAGE  ", LoggerMixin.colorGreenLight),
  debug  (LogManager._kDebugFlag,   " DEBUG ", LoggerMixin.colorBlueDark),
  info   (LogManager._kInfoFlag,    " INFO  ", LoggerMixin.colorCyanLight),
  warming(LogManager._kWarningFlag, "WARMING", LoggerMixin.colorYellowDark),
  error  (LogManager._kErrorFlag,   " ERROR ", LoggerMixin.colorRedLight);
  final int level;
  final String text;
  final String color;
  const MessageLevel(this.level, this.text, this.color);
}

/// 输出日志的级别
enum Level {
  debug(LogManager._kDebug),
  develop(LogManager._kDevelop),
  release(LogManager._kRelease);
  final int value;
  const Level(this.value);
}