import 'package:pp_transfer/pp_transfer.dart';

///
/// Created by a0010 on 2025/1/25 13:07
///
/// 连接状态
abstract interface class Connection {
  /// 是否配对成功
  bool get isPair;

  /// 是否关闭
  bool get isClosed;

  /// 是否正在连接中
  bool get isConnecting;

  /// 是否连接成功
  bool get isConnected;

  /// 是否还存活
  bool get isAlive;

  /// 是否正在传输中
  bool get isTransiting;
}

abstract interface class TimedConnection {
  DateTime? get lastSentTime;

  DateTime? get lastReceivedTime;

  bool isSentRecently(DateTime now);

  bool isReceivedRecently(DateTime now);

  bool isNotReceivedLongTimeAgo(DateTime now);
}

/// 角色
abstract interface class Role {}

/// 发送方
abstract interface class Sender extends Role {
  void addData(IMessage message);
}

/// 接收方
abstract interface class Receiver extends Role {
  void receiveData(IMessage message);
}
