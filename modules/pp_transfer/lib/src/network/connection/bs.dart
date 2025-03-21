import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:fbl/fbl.dart';

///
/// Created by a0010 on 2025/3/3 11:24
///
class BSSocket {
  BSSocket({
    required this.host,
    int? port,
  })  : port = port ?? 1212;
  static const String _tag = 'BSSocket';

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

  bool get isClosed => _socket?.isClosed == true;

  bool get isConnecting => _socket?.isConnecting == true;

  bool get isConnected => _socket?.isConnected == true;

  bool get isAlive => !isClosed && isConnected;

  final String host;

  final int port;

  Future<bool> bind() async {
    _SocketCreator? socket = _socket;
    if (socket != null) {
      Log.e('Socket already connected: socket=$socket', tag: _tag);
      return false;
    }
    socket = _SocketCreator();
    bool result = await socket.bind(host, port);
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

  Future<Uint8List?> read(int maxLen) async {
    if (_caches.isEmpty) {
      return null;
    }

    return _caches.removeAt(0);
  }

  Future<void> close() async {
    await _setSocket(null);
    Log.d('Old socket is closed', tag: _tag);
  }
}

class _SocketCreator {
  _SocketCreator();

  StreamSubscription<Socket>? _subscription;
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

  Future<bool> bind(String host, int port) async {
    return await _bindSocket(host, port);
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
      _subscription?.cancel();
    }
    return true;
  }

  Future<bool> _bindSocket(String host, int port) async {
    if (_connecting) return false;
    _connecting = true;
    try {
      ServerSocket serverSocket = await ServerSocket.bind(host, port);
      var subscription = serverSocket.listen((socket) async {
        socket.port;
        await _setSocket(socket);
      });
      _subscription = subscription;
      return true;
    } catch (e) {
      await _setSocket(null);
      return false;
    }
  }
}
