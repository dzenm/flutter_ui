import 'package:pp_transfer/pp_transfer.dart';

///
/// Created by a0010 on 2025/1/25 13:07
///
/// iOS方式连接
abstract interface class MultipeerConnection {}

/// Wi-Fi Direct连接
abstract interface class WifiDirectConnection {}

/// 蓝牙连接
abstract interface class BleConnection {}

/// Wi-Fi连接
abstract interface class WifiConnection {}

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
