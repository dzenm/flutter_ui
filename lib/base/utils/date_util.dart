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
    } else
      return false;
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
    } else
      return false;
    DateTime? baseDateTime;
    if (other is String) {
      baseDateTime = DateTime.parse(other);
    } else if (other is DateTime) {
      baseDateTime = other;
    }

    return compareDateTime.isAfter(baseDateTime ?? DateTime.now());
  }
}
