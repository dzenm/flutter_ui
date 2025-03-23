import 'dart:convert';
import 'dart:typed_data';

import 'package:fbl/fbl.dart';
import 'package:fbl/src/config/notification.dart' as ln;

import '../../constant/names.dart';
import '../../server/channel.dart';
import '../../server/connection.dart';
import 'device.dart';

mixin ChannelMixin implements Connection {
  final Map<String, Channel?> _sockets = {};

  @override
  bool get isConnected => _isConnected;
  bool _isConnected = false;
  void setConnected() => _isConnected = true;

  @override
  bool get isTransiting => _isTransiting;
  bool _isTransiting = false;
  void setTransiting() => _isTransiting = true;

  Future<void> setSocket(String deviceAddress, Channel? socket) async {
    // 1. replace with new channel
    Channel? old = _sockets[deviceAddress];
    _sockets[deviceAddress] = socket;
    // 2. close old channel
    if (old == null || identical(old, socket)) {
    } else {
      await old.close();
    }
  }

  void sendMsg(String deviceAddress, String text) {
    Channel? socket = _sockets[deviceAddress];
    if (socket == null) return;
    Uint8List data = utf8.encode(text);
    socket.write(data);
    Log.d('发送的数据：text=$text');
  }

  Future<bool> receiveMsg() async {
    bool needWork = false;
    for (var deviceAddress in _sockets.keys) {
      Channel? socket = _sockets[deviceAddress];
      if (socket == null) {
        if (!needWork) needWork = false;
        continue;
      }
      Uint8List? data = await socket.read(0);
      if (data == null) {
        if (!needWork) needWork = false;
        continue;
      }
      if (data.isEmpty) {
        if (!needWork) needWork = false;
        continue;
      }
      String text = utf8.decode(data);
      Log.d('接收的数据：text=$text');
      var nc = ln.NotificationCenter();
      nc.postNotification(WifiDirectNames.kReceiveTextData, this, {
        'text': text,
      });
      needWork = true;
    }
    return needWork;
  }
}

mixin DeviceMixin {
  final Map<String, ServerDevice?> _devices = {};

  ServerDevice? get(String deviceAddress) {
    return _devices[deviceAddress];
  }

  Future<void> setDevice(String deviceAddress, ServerDevice? device) async {
    // 1. replace with new channel
    ServerDevice? old = _devices[deviceAddress];
    _devices[deviceAddress] = device;
    // 2. close old device
    if (old == null || identical(old, device)) {
    } else {
      await old.close();
    }
  }
}
