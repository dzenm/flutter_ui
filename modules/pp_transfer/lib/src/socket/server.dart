import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:fbl/fbl.dart';

import '../server/channel.dart';

///
/// Created by a0010 on 2025/3/3 11:24
///
class BSSocket extends Channel with Logging {
  BSSocket({
    required this.host,
    int? port,
  }) : port = port ?? 1212;
  static const String _tag = 'BSSocket';

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
    socket = _SocketCreator();
    bool result = await socket.bind(host, port);
    if (result) {
      await _setSocket(socket);
    } else {
      await _setSocket(null);
    }
    Log.i('Channel connect finally result=$result', tag: _tag);
    return result;
  }

  @override
  Future<int> write(List<int> data) async {
    return 0;
  }

  @override
  Future<Uint8List?> read(int maxLen) async {
    return null;
  }

  @override
  Future<void> close() async {
    await _setSocket(null);
  }
}

class _SocketCreator with Logging {
  _SocketCreator();

  StreamSubscription<Socket>? _subscription;

  bool get isClosed => _closed;
  bool _closed = true;

  bool get isConnecting => _connecting;
  bool _connecting = false;

  bool get isConnected => _connected;
  bool _connected = false;

  final List<_Socket> _sockets = [];

  Future<bool> bind(String host, int port, [int timeout = 10000]) async {
    return await _bindSocket(host, port);
  }

  Future<bool> close([int timeout = 8000]) async {
    List<_Socket> sockets = _sockets;
    if (sockets.isEmpty) {
      return false;
    } else {
      for (var socket in sockets) {
        await socket.socket.close();
      }
      _subscription?.cancel();
    }
    _closed = true;
    return true;
  }

  void _addSocket(Socket socket) async {
    _Socket sock = _Socket(socket);
    _sockets.add(sock);
    _listen(sock);
  }

  void _listen(_Socket socket) {
    var s = socket.socket;
    s.listen(
      (data) {
        String iMsg = utf8.decode(data);
        logInfo('接收到用户 `userUid=${socket.userUid}` 发送的数据: $iMsg');
        List<_Socket> sockets = _sockets;
        for (var sock in sockets) {
          // 不对发送的客户端进行转发消息
          // if (sock == socket) continue;
          // if (sock.userUid.isEmpty) continue;
          sock.socket.write(iMsg);
          logInfo('转发给用户 `userUid=${sock.userUid}` 消息：$iMsg');
        }
      },
      onError: (err) {},
      onDone: () {
        _removeSocket(socket);
      },
    );
  }

  Future<void> _removeSocket(_Socket socket) async {
    _sockets.removeWhere((sock) => socket == sock);
    socket.socket.close();
  }

  Future<bool> _bindSocket(String host, int port) async {
    if (_connecting) return false;
    _connecting = true;
    try {
      ServerSocket serverSocket = await ServerSocket.bind(host, port);
      var subscription = serverSocket.listen((socket) async {
        _addSocket(socket);
      });
      _subscription = subscription;
      _connected = true;
      _closed = false;
      return true;
    } catch (e) {
      return false;
    }
  }
}

class _Socket {
  final Socket socket;

  _Socket(this.socket);

  void setUserUid(String userUid) => _userUid = userUid;
  String _userUid = '';
  String get userUid => '';

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is _Socket && _userUid == other._userUid;
  }

  @override
  int get hashCode => Object.hash(socket, userUid);
}
