import 'dart:convert';
import 'dart:typed_data';

import 'package:fbl/fbl.dart';
import 'package:fbl/src/config/notification.dart' as ln;
import 'package:pp_transfer/pp_transfer.dart';

import '../../server/channel.dart';
import '../../server/connection.dart';

class ServeDevice {
  final SocketAddress address;

  final WifiP2pDevice device;

  ServeDevice({required this.address, required this.device});

  void setSocket(Channel? socket) => _socket = socket;
  Channel? _socket;
  Channel? get socket => _socket;

  void sendMsg(String text) {
    Channel? socket = _socket;
    if (socket == null) {
      return;
    }

    Uint8List data = utf8.encode(text);
    socket.write(data);
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
      'address': address.remoteAddress,
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
