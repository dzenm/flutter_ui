import 'dart:convert';
import 'dart:typed_data';

import 'package:fbl/fbl.dart';
import 'package:fbl/src/config/notification.dart' as ln;

import '../../constant/names.dart';
import '../../server/channel.dart';
import '../../socket/client.dart';
import '../../socket/owner.dart';
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

mixin ConnectionMixin {
  bool get isPair => _isPair;
  bool _isPair = false; // 是否配对成功

  bool get isConnecting => _isConnecting;
  bool _isConnecting = false; // 是否正在连接中

  bool get isConnected => _isConnected;
  bool _isConnected = false; // 是否连接成功

  Channel? _socket; // 当前连接的socket

  /// 等待发送的数据
  void addPrepareData(List<Uint8List> data) => _data.addAll(data);
  final List<Uint8List> _data = [];

  /// 连接socket
  Future<bool> connectSocket(String host, int port, {int flag = -1}) async {
    _isPair = true;
    Channel? socket = _socket;
    if (socket != null && socket.isConnected) {
      return true;
    }
    if (flag == -1) {
      socket = BSSocket(host: host, port: port);
    } else if (flag == 1) {
      socket = CSSocket(host: host, port: port);
    } else {
      throw Exception('It should not happen');
    }
    if (await socket.connect()) {
      _isConnecting = false;
      _isConnected = true;
      await _setSocket(socket);
      return true;
    }
    _isConnecting = false;
    _isConnected = false;
    await _setSocket(null);
    return false;
  }

  Future<void> _setSocket(Channel? socket) async {
    Channel? old = _socket;
    _socket = socket;
    if (old == null || identical(old, socket)) {
    } else {
      await old.close();
    }
  }

  /// 发送数据
  Future<bool> sendData() async {
    List<Uint8List> dataList = _data;
    if (dataList.isEmpty) {
      return false;
    }
    List<Uint8List> send = [];
    for (var data in dataList) {
      if (!await sendMessage(data)) {
        send.add(data);
      }
    }
    dataList.clear();
    dataList.addAll(send);
    return send.isEmpty;
  }

  /// 发送消息
  Future<bool> sendMessage(Uint8List data) async {
    Channel? socket = _socket;
    if (socket == null || !isConnected) {
      return false;
    }
    await socket.write(data);
    return true;
  }

  /// 发送数据
  Future<bool> receiveData() async {
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
}
