import 'dart:convert';
import 'dart:typed_data';

import 'package:fbl/fbl.dart';
import 'package:fbl/src/config/notification.dart' as ln;
import 'package:fsm/fsm.dart';

import '../../constant/names.dart';
import '../../server/channel.dart';
import '../../socket/client.dart';
import '../../socket/owner.dart';
import '../queue/queue.dart';
import 'codec.dart';
import 'device.dart';
import 'message.dart';

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

/// Socket连接处理
abstract class Hub extends Runner with Logging {
  Hub(super.millis);

  bool get isPair => _isPair;
  bool _isPair = false; // 是否配对成功
  void setPair(bool isPair) => _isPair = isPair;

  bool get isConnecting => _isConnecting;
  bool _isConnecting = false; // 是否正在连接中
  void setConnecting() => _isConnecting = true;

  bool get isConnected => _isConnected;
  bool _isConnected = false; // 是否连接成功

  Channel? _socket; // 当前连接的socket

  /// 连接socket
  Future<bool> connectSocket(String host, int port, {SocketFlag flag = SocketFlag.client}) async {
    if (_isConnecting) {
      return false;
    }
    _isConnecting = true;
    if (_isConnected) {
      return true;
    }
    Channel? socket = _socket;
    if (socket != null && socket.isConnected) {
      return true;
    }
    switch (flag) {
      case SocketFlag.server:
        socket = OwnerChannel(host: host, port: port);
        break;
      case SocketFlag.client:
        socket = ClientChannel(host: host, port: port);
        break;
    }
    if (await socket.connect()) {
      logInfo('连接到 `$host:$port` 成功');
      _isConnecting = false;
      _isConnected = true;
      await _setSocket(socket);
      return true;
    }
    logInfo('连接到 `$host:$port` 失败');
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

  Future<void> close() async {
    await _setSocket(null);
    _isPair = false;
    _isConnecting = false;
    _isConnected = false;
  }
}

/// 发送方
mixin Sender on Hub {
  final IMessageQueue<Message> _queue = IMessageQueue(); // 发送消息的队列

  /// 等待发送的数据
  void addPrepareData(Message message) => _queue.add(message);

  /// 发送数据
  Future<bool> _sendData() async {
    Channel? socket = _socket;
    if (socket == null || !isConnected) {
      return false;
    }
    Log.d('发送的数据：text=_sendData');
    var queue = _queue;
    if (queue.isEmpty) {
      return false;
    }
    var message = queue.poll();
    if (message == null) {
      return false;
    }
    Log.d('发送的数据：text=${message.toJson()}');
    List<int> data = mc.encode(message);
    await socket.write(data);
    return true;
  }
}

/// 接收方
mixin Receiver on Hub {
  /// 发送数据
  Future<bool> _receiveData() async {
    Channel? socket = _socket;
    if (socket == null || !isConnected) {
      return false;
    }
    Uint8List? data = await socket.read(0);
    if (data == null) {
      return false;
    }
    if (data.isEmpty) {
      return false;
    }
    Message message = mc.decode(data);
    Log.d('接收的数据：text=${message.toJson()}');
    var nc = ln.NotificationCenter();
    nc.postNotification(WifiDirectNames.kReceiveTextData, this, {
      'text': message,
    });
    return true;
  }
}

/// Socket管理
class IMManager extends Hub with Sender, Receiver {
  IMManager() : super(Runner.intervalSlow);

  @override
  Future<bool> process() async {
    bool isSend = await _sendData();
    bool isReceive = await _receiveData();
    if (isSend || isReceive) {
      return true;
    }
    return false;
  }
}

/// Socket的类型
enum SocketFlag {
  server(-1),
  client(1);

  final int value;

  const SocketFlag(this.value);

  static SocketFlag parse(int? value) {
    for (var item in SocketFlag.values) {
      if (item.value == value) return item;
    }
    return SocketFlag.client;
  }
}
