import 'state.dart';

///
/// Created by a0010 on 2025/1/25 13:07
///
abstract interface class Connection {
  //  Flags
  bool get isClosed;

  bool get isAlive;

  /// ready for reading
  bool get isAvailable;  // isAlive
  /// ready for writing
  bool get isVacant;     // isAlive

  IMState? get state;
}

///  Connection with sent/received time
abstract interface class TimedConnection {
  DateTime? get lastSentTime;

  DateTime? get lastReceivedTime;

  bool isSentRecently(DateTime now);

  bool isReceivedRecently(DateTime now);

  bool isNotReceivedLongTimeAgo(DateTime now);
}

/// iOS方式连接
abstract interface class MultipeerConnection {}

/// Wi-Fi Direct连接
abstract interface class WifiDirectConnection implements Connection {}

/// 蓝牙连接
abstract interface class BleConnection {}

/// Wi-Fi连接
abstract interface class WifiConnection {}

/// 角色
abstract interface class Role {}

/// 发送方
abstract interface class Sender extends Role {
  List<int> create();
}

/// 接收方
abstract interface class Receiver extends Role {
  void distribute(List<int> data);
}
