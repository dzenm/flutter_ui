///
/// Created by a0010 on 2025/1/25 13:07
///
abstract interface class Connection {
  /// 是否准备好
  bool get isPrepare;

  /// 是否已连接
  bool get isConnected;

  /// 是否在传输中
  bool get isTransiting;
}

/// iOS方式连接
abstract interface class MultipeerConnection implements Connection {}

/// Wi-Fi Direct连接
abstract interface class WifiDirectConnection implements Connection {}

/// 蓝牙连接
abstract interface class BleConnection implements Connection {}

/// Wi-Fi连接
abstract interface class WifiConnection implements Connection {}

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
