import 'package:fbl/fbl.dart';

///
/// Created by a0010 on 2023/3/31 13:45
/// 日期工具类
class DateUtil {
  /// 判断 [dateTime] 是否在 [other] 时间之前，如果 [other] 为空，跟当前时间比较
  /// 如果 [dateTime] 为空，结果为false
  static bool isBefore(dynamic dateTime, {dynamic other}) {
    if (dateTime == null) return false;

    // dateTime 比较不能为空
    DateTime compareDateTime;
    if (dateTime is String) {
      compareDateTime = DateTime.parse(dateTime);
    } else if (dateTime is DateTime) {
      compareDateTime = dateTime;
    } else {
      return false;
    }
    DateTime? baseDateTime;
    if (other is String) {
      baseDateTime = DateTime.parse(other);
    } else if (other is DateTime) {
      baseDateTime = other;
    }

    return compareDateTime.isBefore(baseDateTime ?? DateTime.now());
  }

  /// 判断 [dateTime] 是否在 [other] 时间之后，如果 [other] 为空，跟当前时间比较
  /// 如果 [dateTime] 为空，结果为false
  static bool isAfter(dynamic dateTime, {dynamic other}) {
    if (dateTime == null) return false;

    // dateTime 比较不能为空
    DateTime compareDateTime;
    if (dateTime is String) {
      compareDateTime = DateTime.parse(dateTime);
    } else if (dateTime is DateTime) {
      compareDateTime = dateTime;
    } else {
      return false;
    }
    DateTime? baseDateTime;
    if (other is String) {
      baseDateTime = DateTime.parse(other);
    } else if (other is DateTime) {
      baseDateTime = other;
    }

    return compareDateTime.isAfter(baseDateTime ?? DateTime.now());
  }
}

/// 根据规则 [_pattern] 对 [DateTime] 进行格式化，以下为所有定义的规则，可进行组合展示
///     Symbol   Meaning                Presentation       Example
///     ------   -------                ------------       -------
///     yyyy     year                   (Number)           1996
///     MM       month in year          (Number)           07
///     dd       day in month           (Number)           10
///     HH       hour in day (0~23)     (Number)           21
///     hh       hour in am/pm (1~12)   (Number)           11
///     mm       minute in hour         (Number)           45
///     ss       second in minute       (Number)           55
///     SSS      fractional second      (Number)           978
///     EEE      day of week            (Text)             Tuesday
class DateFormat {
  static const _y = 'y';
  static const _mon = 'M';
  static const _day = 'd';
  static const _hour = 'H';
  static const _hou = 'h';
  static const _min = 'm';
  static const _sec = 's';
  static const _mill = 'S';
  static const _week = 'E';

  late String _pattern;

  /// 接收一个格式化的规则
  /// 例：
  ///  var format = DateFormat('yyyy/MM/dd HH:mm:ss SSS EEE')
  ///  print(format.format(now)) // 2024/08/01 11:39:39 062 thursday
  DateFormat([String? pattern]) {
    _pattern = pattern ?? 'yyyy/MM/dd HH:mm:ss SSS EEE';
  }

  /// 将 [date] 根据规则 [_pattern] 进行格式化
  String format(DateTime date) {
    StringBuffer result = StringBuffer();

    var patterns = _patterns;

    int i = 0;
    while (i < patterns.length) {
      String tmp = patterns[i++];
      if (tmp == _y) {
        result.write(date.year);
      } else if (tmp == _mon) {
        result.write(_two(date.month));
      } else if (tmp == _day) {
        result.write(_two(date.day));
      } else if (tmp == _hour) {
        result.write(_two(date.hour));
      } else if (tmp == _hou) {
        result.write(_two(date.hour % 12));
      } else if (tmp == _min) {
        result.write(_two(date.minute));
      } else if (tmp == _sec) {
        result.write(_two(date.second));
      } else if (tmp == _mill) {
        result.write(_three(date.millisecond));
      } else if (tmp == _week) {
        Weekday today = Weekday.monday;
        for (var week in Weekday.values) {
          if (date.weekday == week.day) today = week;
        }
        result.write(today.name);
      } else {
        result.write(tmp);
      }
    }

    return result.toString();
  }

  /// 将 [value] 转为两位数字的字符串，如果 [value] 不足两位，前面会补0
  /// 例：
  ///  print(_two(7)); // '07'
  ///  print(_two(12)); // '12'
  String _two(int value) => '$value'.padLeft(2, '0').substring(0, 2);

  /// 将 [value] 转为三位数字的字符串，如果 [value] 不足三位，前面会补0
  /// 例：
  ///  print(_two(7)); // '007'
  ///  print(_two(12)); // '012'
  ///  print(_two(999)); // '999'
  String _three(int value) => '$value'.padLeft(3, '0').substring(0, 3);

  /// 对每一位字符串进行处理，与前一位不一致的字符串进行保存
  /// 例：
  ///  _pattern='yyyy/MM/dd'
  ///  print(_patterns) // ['y', '/', 'M', '/', 'd']
  List<String> get _patterns {
    List<String> patterns = [];
    if (_pattern.isEmpty) return patterns;

    int i = 0;
    patterns.add(_pattern[i]);
    while (++i < _pattern.length) {
      if (_pattern[i - 1] == _pattern[i]) continue;
      patterns.add(_pattern[i]);
    }
    return patterns;
  }

  /// 将字符串 [formatString] 解析为 [DateTime] 的值
  /// 例：
  ///  DateFormat format = DateFormat();
  ///  print(format.parse('2024/8/1 13:22:47 787')); // 2024-08-01 13:22:47.787
  DateTime parse(String formatString) {
    assert(formatString.isNotEmpty, 'DateFormat\'s can\'t parse empty string');

    // 将字符串的连续数字解析并保存在列表中
    List<StringBuffer> digits = [StringBuffer()];
    int i = -1;
    while (++i < formatString.length) {
      var s = formatString[i];
      if (_isDigit(s)) {
        digits.last.write(s);
      } else if (digits.last.isNotEmpty) {
        digits.add(StringBuffer());
      }
    }

    // 将连续数字的字符串转为数字按顺序存在相应的int值
    List<String> list = digits.map((e) => e.toString()).toList();
    int year = 0, month = 1, day = 1, hour = 0, minute = 0, second = 0, millisecond = 0;
    for (int i = 0; i < digits.length; i++) {
      if (digits[i].isEmpty) continue;

      if (i == 0) {
        year = int.parse(list[0]);
      } else if (i == 1) {
        month = int.parse(list[1]);
      } else if (i == 2) {
        day = int.parse(list[2]);
      } else if (i == 3) {
        hour = int.parse(list[3]);
      } else if (i == 4) {
        minute = int.parse(list[4]);
      } else if (i == 5) {
        second = int.parse(list[5]);
      } else if (i == 6) {
        millisecond = int.parse(list[6]);
      }
    }
    DateTime date = DateTime(year, month, day, hour, minute, second, millisecond);
    return date;
  }

  /// 判断字符 [s] 是否是数字
  bool _isDigit(String s) {
    if (s.isEmpty) return false;
    int val = s.runes.first;
    return val >= 48 && val <= 57;
  }
}

enum Weekday {
  monday(1),
  tuesday(2),
  wednesday(3),
  thursday(4),
  friday(5),
  saturday(6),
  sunday(7);

  final int day;

  const Weekday(this.day);
}
