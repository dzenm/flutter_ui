import 'dart:io';
import 'dart:typed_data';

import 'package:fbl/fbl.dart';

import '../server/channel.dart';

/// Socket连接超时重连时间
const int _kSocketTimeout = 30000;

///
/// Created by a0010 on 2025/3/3 11:23
///
class ClientChannel extends Channel with Logging {
  ClientChannel({
    required this.host,
    int? port,
  }) : port = port ?? 1212;
  static const String _tag = 'CSSocket';

  /// 处理接收的字节数据，每次接收的数据长度不一样，先缓存下来，再进行处理
  final List<Uint8List> _caches = [];
  _SocketCreator? _socket;

  Future<void> _setSocket(_SocketCreator? socket) async {
    // 1. replace with new channel
    _SocketCreator? old = _socket;
    _socket = socket;
    // 2. close old channel
    if (old == null || identical(old, socket)) {
    } else {
      await old.close();
    }
  }

  @override
  bool get isClosed => _socket?.isClosed == true;

  @override
  bool get isConnecting => _socket?.isConnecting == true;

  @override
  bool get isConnected => _socket?.isConnected == true;

  @override
  bool get isAlive => !isClosed && isConnected;

  final String host;

  final int port;

  @override
  Future<bool> connect() async {
    _SocketCreator? socket = _socket;
    if (socket != null) {
      Log.e('Socket already connected: socket=$socket', tag: _tag);
      return false;
    }
    socket = _SocketCreator(host, port);
    bool result = await socket.connect();
    if (result) {
      await _setSocket(socket);
      _caches.clear();
      // read buffer
      socket.listen((data) {
        _caches.add(data);
      });
    } else {
      await _setSocket(null);
    }
    Log.i('Channel connect finally result=$result', tag: _tag);
    return result;
  }

  @override
  Future<int> write(List<int> data) async {
    _SocketCreator? socket = _socket;
    if (socket == null) {
      Log.e('Socket not connect: socket=$socket', tag: _tag);
      return -1;
    } else if (data.isEmpty) {
      return 0;
    }
    return await socket.write(data);
  }

  @override
  Future<Uint8List?> read(int maxLen) async {
    if (_caches.isEmpty) {
      return null;
    }

    return _caches.removeAt(0);
  }

  @override
  Future<void> close() async {
    await _setSocket(null);
    Log.d('Old socket is closed', tag: _tag);
  }
}

class _SocketCreator {
  String host;
  int port;

  _SocketCreator(this.host, this.port);

  Socket? _socket;

  bool get isClosed => _closed;
  bool _closed = true;

  bool get isConnecting => _connecting;
  bool _connecting = false;

  bool get isConnected => _connected;
  bool _connected = false;

  Future<bool> _setSocket(Socket? socket) async {
    bool isNull = socket == null;
    // 1. replace with new socket
    Socket? old = _socket;
    if (!isNull) {
      _socket = socket;
      // } else {
      //   _ws = null;
    }
    // 2. close old socket
    if (old == null || identical(old, socket)) {
    } else {
      await old.close();
    }
    _closed = isNull;
    _connecting = false;
    _connected = !isNull;
    return isConnected;
  }

  Future<bool> connect([int timeout = 10000]) async {
    await _connectSocket();
    if (await _checkState(timeout, () => _connected)) {
      return true;
    } else {
      return false;
    }
  }

  void listen(void Function(Uint8List data) onData) => _socket?.listen(
        (data) => onData(data),
        onError: (err) {},
        onDone: () {
          close();
        },
      );

  Future<int> write(List<int> data) async {
    Socket? socket = _socket;
    if (socket == null || !_connected) {
      return -1;
    }
    socket.add(data);
    return data.length;
  }

  Future<bool> close([int timeout = 8000]) async {
    Socket? socket = _socket;
    if (socket == null) {
      return false;
    } else {
      await _setSocket(null);
    }
    return await _checkState(timeout, () => _closed);
  }

  Future<bool> _connectSocket() async {
    if (_connecting) return false;
    _connecting = true;
    try {
      Duration timeout = const Duration(milliseconds: _kSocketTimeout);
      Socket socket = await Socket.connect(
        host,
        port,
        timeout: timeout,
      );
      await _setSocket(socket);
      return true;
    } catch (e) {
      await _setSocket(null);
      return false;
    }
  }

  Future<bool> _checkState(int timeout, bool Function() condition) async {
    if (timeout <= 0) {
      // non-blocking
      return true;
    }
    DateTime expired = DateTime.now().add(Duration(milliseconds: timeout));
    while (!condition()) {
      // condition not true, wait a while to check again
      await Future.delayed(const Duration(milliseconds: 128));
      if (DateTime.now().isAfter(expired)) {
        return false;
      }
    }
    // condition true now
    return true;
  }
}
