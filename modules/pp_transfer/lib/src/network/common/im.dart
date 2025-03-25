import 'dart:convert';
import 'dart:typed_data';

import 'package:fbl/fbl.dart';
import 'package:fbl/src/config/notification.dart' as ln;

import '../../constant/names.dart';
import '../../server/channel.dart';
import '../../socket/bs.dart';
import 'device.dart';

/// 设备处理
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

  void clearAll() {
    _allDevices.clear();
  }
}

/// 客户端处理
mixin ClientMixin {
  Future<void> setClient(Channel? socket) async {
    // 1. replace with new socket
    Channel? old = _client;
    _client = socket;
    // 2. close old socket
    if (old == null || identical(old, socket)) {
    } else {
      await old.close();
    }
  }

  Channel? _client;

  Channel? get client => _client;

  void sendMsg(String text) {
    Channel? socket = _client;
    if (socket == null) {
      return;
    }

    Uint8List data = utf8.encode(text);
    socket.write(data);
  }

  Future<bool> receiveMsg() async {
    Channel? socket = _client;
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
    Channel? socket = _client;
    if (socket == null) {
      return;
    }
    await socket.close();
  }
}

/// 服务端处理
mixin ServerMixin {
  Channel? _server;

  Channel? get server => _server;

  Future<void> setServer(Channel socket) async {
    // 1. replace with new socket
    Channel? old = _server;
    _server = socket;
    // 2. close old socket
    if (old == null || identical(old, socket)) {
    } else {
      await old.close();
    }
  }

  Future<void> disconnect() async {
    Channel? socket = _server;
    if (socket == null) {
      return;
    }
    await socket.close();
  }
}
