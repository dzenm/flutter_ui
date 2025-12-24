///
/// Created by a0010 on 2025/10/22 15:25
/// 日期处理
final class Date {
  /// 2025-10-23 16:27:59 987654
  /// 获取当前时间的字符串
  static String formatNow() {
    Date format = Date._now();
    return format.toString();
  }

  /// 2025-10-23 16:27:59 987654
  /// 获取当前时间
  static Date now() {
    Date format = Date._now();
    return format;
  }

  /// 将 [data] 转化为 [Date]，可能为空
  static Date? fromDate(String? data) {
    if (data == null) {
      return null;
    }
    DateTime? dateTime = DateTime.tryParse(data);
    if (dateTime == null) {
      return null;
    }
    return Date.dt(dateTime);
  }

  /// 将 [data] 转化为 [String]，可能为空
  static String toDate(Date? data) {
    if (data == null) {
      return "";
    }
    return data.ymdHms;
  }

  /// 格式化 [d] 为HH:mm:ss，9:07:05 -> 09:07:05
  static String formatDurationHMS(Duration d) {
    var microseconds = d.inMicroseconds;
    var negative = microseconds < 0;

    var hours = microseconds ~/ Duration.microsecondsPerHour;
    microseconds = microseconds.remainder(Duration.microsecondsPerHour);
    var hoursPadding = hours < 10 ? "0" : "";

    if (negative) {
      hours = 0 - hours; // Not using `-hours` to avoid creating -0.0 on web.
      microseconds = 0 - microseconds;
    }

    var minutes = microseconds ~/ Duration.microsecondsPerMinute;
    microseconds = microseconds.remainder(Duration.microsecondsPerMinute);
    var minutesPadding = minutes < 10 ? "0" : "";

    var seconds = microseconds ~/ Duration.microsecondsPerSecond;
    microseconds = microseconds.remainder(Duration.microsecondsPerSecond);
    var secondsPadding = seconds < 10 ? "0" : "";

    return "$hoursPadding$hours:"
        "$minutesPadding$minutes:"
        "$secondsPadding$seconds";
  }

  /// 格式化 [inSeconds] 为 mm:ss，678 -> 11:18
  static String formatSeconds(int inSeconds) {
    var minutes = inSeconds ~/ 60;
    inSeconds = inSeconds.remainder(60);
    var minutesPadding = minutes < 10 ? "0" : "";

    var seconds = inSeconds;
    var secondsPadding = inSeconds < 10 ? "0" : "";

    return "$minutesPadding$minutes:"
        "$secondsPadding$seconds";
  }

  /// 1   -> 01
  /// 76  -> 76
  /// 如果是一位的数字前面补0
  static String t(int val) => "${val < 10 ? "0" : ""}$val";

  /// 6   ->  06
  /// 39  -> 039
  /// 519 -> 519
  /// 如果是一位的数字前面补00, 两位的前面补0
  static String f(int val) => "${val < 10 ? "00" : val < 100 ? "0" : ""}$val";

  static int td(num ms) => th(ms) ~/ 24; // 天数
  static int th(num ms) => tm(ms) ~/ 60; // 时钟
  static int tm(num ms) => ts(ms) ~/ 60; // 分钟
  static int ts(num ms) => ms ~/ 1000; // 秒钟

  Date(String? source) {
    DateTime dateTime = DateTime.tryParse(source ?? "") ?? DateTime.now();
    _parse(dateTime);
  }

  Date.dt(DateTime source) {
    _parse(source);
  }

  Date.ms(int millisecondsSinceEpoch) {
    var dateTime = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    _parse(dateTime);
  }

  Date._now() {
    _parse(DateTime.now());
  }

  void _parse(DateTime dateTime) {
    _dateTime = dateTime;
    _yea = dateTime.year;
    _mon = dateTime.month;
    _day = dateTime.day;
    _hou = dateTime.hour;
    _min = dateTime.minute;
    _sec = dateTime.second;
    _mil = dateTime.millisecond;
    _mic = dateTime.microsecond;
    _milS = dateTime.millisecondsSinceEpoch;
    _micS = dateTime.microsecondsSinceEpoch;
  }

  DateTime get dateTime => _dateTime;
  late DateTime _dateTime; // 时间日期
  int get year => _yea;
  int _yea = 0; // 年份 2025
  int get month => _mon;
  int _mon = 0; // 月份 9
  int get day => _day;
  int _day = 0; // 日期 6
  int get hour => _hou;
  int _hou = 0; // 小时 12
  int get minute => _min;
  int _min = 0; // 分钟 5
  int get second => _sec;
  int _sec = 0; // 秒钟 1
  int get millisecond => _mil;
  int _mil = 0; // 毫秒 876
  int get microsecond => _mic;
  int _mic = 0; // 微秒 984
  int get millisecondsSinceEpoch => _milS;
  int _milS = 0; // 毫秒时间戳
  int get microsecondsSinceEpoch => _micS;
  int _micS = 0; // 微秒时间戳

  /// 1997-01
  String get ym => "$_yea-${t(_mon)}"; //
  /// 1997-01-01
  String get ymd => "$_yea-${t(_mon)}-${t(_day)}"; //
  /// 1997.01.01
  String get ymdD => "$_yea.${t(_mon)}.${t(_day)}"; //
  /// 1997-01-01 11:59
  String get ymdHm => "$_yea-${t(_mon)}-${t(_day)} "
      "${t(_hou)}:${t(_min)}"; //
  /// 1997-01-01 11:59:59
  String get ymdHms => "$_yea-${t(_mon)}-${t(_day)} "
      "${t(_hou)}:${t(_min)}:${t(_sec)}"; //
  /// 1997.01.01 11:59:59
  String get ymdHmsD => "$_yea.${t(_mon)}.${t(_day)} "
      "${t(_hou)}:${t(_min)}:${t(_sec)}"; //
  /// 1997-01-01 11:59:59.789
  String get ymdHmsS => "$_yea-${t(_mon)}-${t(_day)} "
      "${t(_hou)}:${t(_min)}:${t(_sec)}."
      "${f(_mil)}"; //
  /// 1997-01-01 11:59:59.789
  String get ymdHmsSS => "$_yea-${t(_mon)}-${t(_day)} "
      "${t(_hou)}:${t(_min)}:${t(_sec)}."
      "${f(_mil)}${f(_mic)}"; //
  /// 01-01
  String get md => "${t(_mon)}-${t(_day)}"; //
  /// 01-01 11:59
  String get mdHm => "${t(_mon)}-${t(_day)} "
      "${t(_hou)}:${t(_min)}"; //
  /// 1月1日
  String get mdString => "$_mon月$_day日"; //
  /// 1月
  String get mString => "$_mon月"; //
  /// 11:59:59
  String get hms => "${t(_hou)}:${t(_min)}:${t(_sec)}"; //
  /// 11:59:59 789
  String get hmsS => "${t(_hou)}:${t(_min)}:${t(_sec)} "
      "${f(_mil)}"; //
  /// 11:59
  String get hm => "${t(_hou)}:${t(_min)}"; //

  @override
  bool operator ==(Object other) {
    return other is Date && //
        isAtSameMomentAs(other) &&
        hashCode == other.hashCode;
  }

  /// 比较大小
  bool operator >(Date other) =>
      isAfter(other) && //
      _dateTime.isAfter(other._dateTime);

  /// 比较大小
  bool operator <(Date other) =>
      isBefore(other) && //
      _dateTime.isBefore(other._dateTime);

  @override
  String toString() => ymdHmsSS;

  @override
  int get hashCode => Object.hash(
        _yea,
        _mon,
        _day,
        _hou,
        _min,
        _sec,
        _mil,
        _mic,
        _milS,
        _micS,
      );
}

extension DateExt on Date {
  /// 是否是相同的时刻
  /// [other] 需要比较的时间，接受格式化的 [String] 、 [DateTime] 、 [Date] 类型
  bool isAtSameMomentAs(dynamic other) {
    Date format = _getDate(other);
    return _dateTime.isAtSameMomentAs(format._dateTime);
  }

  /// 比较是否靠后
  /// [other] 需要比较的时间，接受格式化的 [String] 、 [DateTime] 、 [Date] 类型
  bool isAfter(dynamic other) {
    Date format = _getDate(other);
    return millisecondsSinceEpoch > format.millisecondsSinceEpoch;
  }

  /// 比较是否靠后
  bool isAfterNow() {
    Date date = Date._now();
    return millisecondsSinceEpoch > date.millisecondsSinceEpoch;
  }

  /// 比较是否靠前
  /// [other] 需要比较的时间，接受格式化的 [String] 、 [DateTime] 、 [Date] 类型
  bool isBefore(dynamic other) {
    Date format = _getDate(other);
    return millisecondsSinceEpoch < format.millisecondsSinceEpoch;
  }

  /// 比较是否靠前
  bool isBeforeNow() {
    Date date = Date._now();
    return millisecondsSinceEpoch < date.millisecondsSinceEpoch;
  }

  /// 比较添加 [duration] 后与当前时间相比是否靠后
  /// [duration] 时间间隔
  bool isAfterDuration(Duration duration) {
    Date now = Date.now();
    Date d = add(duration);
    return d.millisecondsSinceEpoch > now.millisecondsSinceEpoch;
  }

  /// 比较添加 [duration] 后与当前时间相比是否靠前
  /// [duration] 时间间隔
  bool isBeforeDuration(Duration duration) {
    Date now = Date.now();
    Date d = add(duration);
    return d.millisecondsSinceEpoch < now.millisecondsSinceEpoch;
  }

  /// 加上一个时间间隔
  /// [duration] 时间间隔
  Date add(Duration duration) => Date.dt(_dateTime.add(duration));

  /// 减去一个时间间隔
  /// [duration] 时间间隔
  Date subtract(Duration duration) => Date.dt(_dateTime.subtract(duration));

  /// 相减得到的时间差
  /// [other] 需要比较的时间，接受格式化的 [String] 、 [DateTime] 、 [Date] 类型
  Duration difference(dynamic other) {
    Date format = _getDate(other);
    return _dateTime.difference(format.dateTime);
  }

  /// 比较是否是不同年份
  /// [other] 需要比较的时间，接受格式化的 [String] 、 [DateTime] 、 [Date] 类型
  bool isDifferentYear(dynamic other) {
    Date format = _getDate(other);
    return _yea != format._yea;
  }

  /// 比较是否是不同年份/月份
  /// [other] 需要比较的时间，接受格式化的 [String] 、 [DateTime] 、 [Date] 类型
  bool isDifferentYM(dynamic other) {
    Date format = _getDate(other);
    return _yea != format._yea || //
        _mon != format._mon;
  }

  /// 比较是否是不同年份/月份/日期
  /// [other] 需要比较的时间，接受格式化的 [String] 、 [DateTime] 、 [Date] 类型
  bool isDifferentYMD(dynamic other) {
    Date format = _getDate(other);
    return _yea != format._yea || //
        _mon != format._mon || //
        _day != format._day;
  }

  /// 比较时间的大小
  int compareTo(dynamic other) {
    Date format = _getDate(other);
    return millisecondsSinceEpoch.compareTo(format.millisecondsSinceEpoch);
  }

  /// 获取格式化后的 [Date]
  Date _getDate(dynamic other) {
    Date? format;
    if (other is String) {
      format = Date(other);
    }
    if (other is DateTime) {
      format = Date.dt(other);
    }
    if (other is Date) {
      format = other;
    }
    if (format == null) {
      throw Exception("Params `other` is ${other.runtimeType}, It can't process");
    }
    return format;
  }

  /// 获取到今天的天数
  int get daysUpToToday {
    Date now = Date.now();
    int days = difference(now).inDays;
    // 处理今天但未到具体时间的情况（多算1天） 距离今天
    if (days == 0 && isAfter(now)) {
      return 1;
    }
    return days < 0 ? 0 : days;
  }

  /// 今天：显示时分；
  /// 昨天：显示昨天；
  /// 其他：显示年月日
  String get formatTwoDays {
    Date now = Date._now();
    if (now._yea == _yea) {
      if (now._mon == _mon) {
        if (now._day == _day) {
          return hm;
        }
        if (now._day - 1 == _day) {
          return "昨天";
        }
      }
    }
    return ymd;
  }

  /// 今天：显示时分；
  /// 昨天：显示昨天时分；
  /// 周内：显示N天前时分；
  /// 其他：显示年月日时分
  String get formatWeeks {
    Date now = Date._now();
    if (now._yea == _yea) {
      if (now._mon == _mon) {
        if (now._day == _day) {
          return hm;
        }
        if (now._day - 1 == _day) {
          return "昨天$hm";
        }
        int days = now._day - _day;
        if (days <= 7) {
          return "$days天前$hm";
        }
      }
      return mdHm;
    }
    return ymdHm;
  }

  /// 今天：显示时分
  /// 其他：显示年月日时分
  String get formatDate {
    Date now = Date._now();
    if (now._yea == _yea) {
      if (now._mon == _mon) {
        if (now._day == _day) {
          return hm;
        }
      }
      return mdHm;
    }
    return ymdHm;
  }
}

final class Time implements Comparable<Time> {
  final int _duration;

  const Time({
    int days = 0,
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
    int milliseconds = 0,
    int microseconds = 0,
  }) : this.ms(microseconds +
            Duration.microsecondsPerMillisecond * milliseconds +
            Duration.microsecondsPerSecond * seconds +
            Duration.microsecondsPerMinute * minutes +
            Duration.microsecondsPerHour * hours +
            Duration.microsecondsPerDay * days);

  const Time.second(int seconds)
      : this.ms(
          seconds * Duration.microsecondsPerSecond,
        );

  const Time.ms(int duration) : _duration = duration + 0;

  int get days {
    var duration = _duration;
    var days = duration ~/ Duration.microsecondsPerDay;
    return days;
  }

  int get inDays => _duration ~/ Duration.microsecondsPerDay;

  int get hours {
    var duration = _duration;
    duration = duration.remainder(Duration.microsecondsPerDay);
    var hours = duration ~/ Duration.microsecondsPerHour;
    return hours;
  }

  int get inHours => _duration ~/ Duration.microsecondsPerHour;

  int get minutes {
    var duration = _duration;
    duration = duration.remainder(Duration.microsecondsPerDay);
    duration = duration.remainder(Duration.microsecondsPerHour);
    var minutes = duration ~/ Duration.microsecondsPerMinute;
    return minutes;
  }

  int get inMinutes => _duration ~/ Duration.microsecondsPerMinute;

  int get seconds {
    var duration = _duration;
    duration = duration.remainder(Duration.microsecondsPerDay);
    duration = duration.remainder(Duration.microsecondsPerHour);
    duration = duration.remainder(Duration.microsecondsPerMinute);
    var seconds = duration ~/ Duration.microsecondsPerSecond;
    return seconds;
  }

  int get inSeconds => _duration ~/ Duration.microsecondsPerSecond;

  int get milliseconds {
    var duration = _duration;
    duration = duration.remainder(Duration.microsecondsPerDay);
    duration = duration.remainder(Duration.microsecondsPerHour);
    duration = duration.remainder(Duration.microsecondsPerMinute);
    duration = duration.remainder(Duration.microsecondsPerSecond);
    var milliseconds = duration ~/ Duration.microsecondsPerMillisecond;
    return milliseconds;
  }

  int get inMilliseconds => _duration ~/ Duration.microsecondsPerMillisecond;

  int get microseconds {
    var duration = _duration;
    duration = duration.remainder(Duration.microsecondsPerDay);
    duration = duration.remainder(Duration.microsecondsPerHour);
    duration = duration.remainder(Duration.microsecondsPerMinute);
    duration = duration.remainder(Duration.microsecondsPerSecond);
    duration = duration.remainder(Duration.microsecondsPerMillisecond);
    var microseconds = duration ~/ Duration.microsecondsPerMillisecond;
    return microseconds;
  }

  int get inMicroseconds => _duration;

  /// 7天4时36分15秒
  String get timeString => "$days天$hours小时$minutes分$seconds秒"; //
  /// 09:35
  String get hm => "${Date.t(hours)}:${Date.t(minutes)}"; //
  /// 09:35:51
  String get hms => "${Date.t(hours)}:${Date.t(minutes)}:${Date.t(seconds)}"; //

  @override
  bool operator ==(Object other) => other is Time && _duration == other.inMicroseconds;

  @override
  int get hashCode => _duration.hashCode;

  @override
  int compareTo(Time other) => _duration.compareTo(other._duration);

  Duration toDuration() {
    return Duration(
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: milliseconds,
      microseconds: microseconds,
    );
  }
}
