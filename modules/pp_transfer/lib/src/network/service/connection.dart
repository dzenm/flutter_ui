///
/// Created by a0010 on 2025/1/25 13:07
///
abstract interface class Connection {
  /// 是否准备好
  Future<bool> get isPrepare;

  /// 是否已连接
  bool get isConnected;

  /// 是否在传输中
  bool get isTransiting;
}

abstract interface class Executor {

  Future<bool> initialize();

  void connect(String deviceAddress);

  void dispose();
}

/// iOS方式连接
abstract interface class MultipeerConnection implements Connection, Executor {}

/// Wi-Fi Direct连接
abstract interface class WifiDirectConnection implements Connection, Executor {}

/// 蓝牙连接
abstract interface class BleConnection implements Connection, Executor {}

/// Wi-Fi连接
abstract interface class WifiConnection implements Connection, Executor {}

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
