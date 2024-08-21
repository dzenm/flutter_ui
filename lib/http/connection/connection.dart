import 'package:fsm/fsm.dart';

/// Connection State
abstract interface class Connection implements Ticker {
  //  Flags
  bool get isClosed; // !isOpen()
  bool get isBound;

  bool get isConnected;

  bool get isAlive; // isOpen && (isConnected || isBound)

  /// ready for reading
  bool get isAvailable; // isAlive
  /// ready for writing
  bool get isVacant; // isAlive

  Future<void> start() async {}

  Future<void> close() async {}

  @override
  Future<void> tick(DateTime now, int elapsed) async {}
}

///  Connection with sent/received time
abstract interface class TimedConnection {
  DateTime? get lastSentTime;

  DateTime? get lastReceivedTime;

  bool isSentRecently(DateTime now) {
    if (lastSentTime == null) return false;
    if (lastSentTime!.add(const Duration(minutes: 5)).isBefore(now)) {
      return true;
    }
    return false;
  }

  bool isReceivedRecently(DateTime now) {
    if (lastReceivedTime == null) return false;
    if (lastReceivedTime!.add(const Duration(minutes: 5)).isBefore(now)) {
      return true;
    }
    return false;
  }

  bool isNotReceivedLongTimeAgo(DateTime now) {
    if (!isSentRecently(now)) {
      return false;
    }
    if (!isReceivedRecently(now)) {
      return false;
    }
    if (lastReceivedTime!.isBefore(lastSentTime!)) {
      return true;
    }
    return false;
  }
}

mixin IMConnection implements Connection, TimedConnection {

}
