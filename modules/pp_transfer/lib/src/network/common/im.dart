import 'dart:convert';
import 'dart:typed_data';

import 'package:fbl/fbl.dart';
import 'package:fbl/src/config/notification.dart' as ln;

import '../../constant/names.dart';
import '../../server/channel.dart';
import '../../server/connection.dart';
import 'device.dart';

mixin DeviceMixin {
  final Map<String, ServeDevice?> _allDevices = {};

  ServeDevice? get(String deviceAddress) {
    return _allDevices[deviceAddress];
  }

  Future<void> setDevice(String deviceAddress, ServeDevice? device) async {
    // 1. replace with new device
    ServeDevice? old = _allDevices[deviceAddress];
    _allDevices[deviceAddress] = device;
    // 2. close old device
    if (old == null || identical(old, device)) {
    } else {
      await old.close();
    }
  }

  Future<void> setSocket(String deviceAddress, Channel? socket) async {
    // 1. replace with new socket
    Channel? old = _allDevices[deviceAddress]?.socket;
    _allDevices[deviceAddress]?.setSocket(socket);
    // 2. close old socket
    if (old == null || identical(old, socket)) {
    } else {
      await old.close();
    }
  }
}

mixin ClientMixin {
  Future<void> setSocket(Channel? socket) async {
    // 1. replace with new socket
    Channel? old = _socket;
    _socket = socket;
    // 2. close old socket
    if (old == null || identical(old, socket)) {
    } else {
      await old.close();
    }
  }
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

mixin ServerMixin implements ClientMixin {
  final Map<String, Channel?> _allSockets = {};

  Channel? get(String deviceAddress) {
    return _allSockets[deviceAddress];
  }

  Future<void> addSocket(String deviceAddress, Channel? socket) async {
    // 1. replace with new socket
    Channel? old = _allSockets[deviceAddress];
    _allSockets[deviceAddress] = socket;
    // 2. close old socket
    if (old == null || identical(old, socket)) {
    } else {
      await old.close();
    }
  }

  /// 转发消息
  Future<void> transform() async {
    socket.cast<List<int>>().transform(utf8.decoder).listen((event) {
      //     print(event);
      //     socket.write("Niyehaoa");
      // });
  }
}


mixin ChannelMixin implements DeviceMixin {

  void sendMsg(String deviceAddress, String text) {
    ServeDevice? device = _allDevices[deviceAddress];
    if (device == null) return;
    device.sendMsg(text);
    Log.d('发送的数据：deviceAddress=$deviceAddress, text=$text');
  }

  Future<bool> receiveMsg() async {
    bool needWork = false;
    for (var deviceAddress in _allDevices.keys) {
      ServeDevice? device = _allDevices[deviceAddress];
      if (device == null) {
        if (!needWork) needWork = false;
        continue;
      }
      bool result = await device.receiveMsg();
      if (result) needWork = true;
    }
    return needWork;
  }
}

