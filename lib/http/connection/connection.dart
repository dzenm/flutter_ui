import '../../base/fsm/ticker.dart';
import 'state.dart';

class Connection implements Ticker {
  //  Flags
  bool isClosed = true; // !isOpen()
  bool isBound = true;

  bool get isConnected => true;

  bool isAlive = false; // isOpen && (isConnected || isBound)

  /// ready for reading
  bool get isAvailable => true; // isAlive
  /// ready for writing
  bool get isVacant => true; // isAlive

  ConnectionState? get state => null;

  Future<void> close() async {}

  @override
  Future<void> tick(DateTime now, int elapsed) async {}
}

///  Connection with sent/received time
abstract interface class TimedConnection {
  DateTime? get lastSentTime;

  DateTime? get lastReceivedTime;

  bool isSentRecently(DateTime now);

  bool isReceivedRecently(DateTime now);

  bool isNotReceivedLongTimeAgo(DateTime now);
}
