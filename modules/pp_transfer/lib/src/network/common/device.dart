import 'dart:convert';
import 'dart:typed_data';

import 'package:fbl/fbl.dart';
import 'package:fbl/src/config/notification.dart' as ln;
import 'package:pp_transfer/pp_transfer.dart';

import '../../server/channel.dart';
import '../../server/connection.dart';

class ServerDevice implements Connection {
  final SocketAddress address;

  final WifiP2pDevice device;

  ServerDevice({required this.address, required this.device});

  @override
  bool get isConnected => _isConnected;
  bool _isConnected = false;
  void setConnected() => _isConnected = true;

  @override
  bool get isTransiting => _isTransiting;
  bool _isTransiting = false;
  void setTransiting() => _isTransiting = true;

  void setSocket(Channel socket) => _socket = socket;
  Channel? _socket;
  void sendMsg(String deviceAddress, String text) {
    Channel? socket = _socket;
    if (socket == null) {
      return;
    }

    Uint8List data = utf8.encode(text);
    socket.write(data);
    Log.d('发送的数据：text=$text');
  }

  Future<bool> receiveMsg() async {
    Channel? socket = _socket;
    if (socket == null) {
      return false;
    }
    Uint8List? data = await socket.read(0);
    if (data == null) {
      return false;
    }
    if (data.isEmpty) {
      return false;
    }
    String text = utf8.decode(data);
    Log.d('接收的数据：text=$text');
    var nc = ln.NotificationCenter();
    nc.postNotification(WifiDirectNames.kReceiveTextData, this, {
      'text': text,
    });
    return true;
  }

  Future<void> close() async {
    Channel? socket = _socket;
    if (socket == null) {
      return;
    }
    await socket.close();
  }
}
