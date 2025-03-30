import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:fbl/fbl.dart';

import '../server/channel.dart';

class ServerChannel extends Channel with Logging {
  ServerChannel({
    required this.host,
    required this.port,
  });

  static const String _tag = 'ServerChannel';

  _SocketCreator? _socket;

  Future<void> _setSocket(_SocketCreator? socket) async {
    _SocketCreator? old = _socket;
    _socket = socket;
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
  Future<int> write(List<int> data, {String? userUid}) async {
    _SocketCreator? socket = _socket;
    if (socket == null) {
      Log.e('Socket not connect: socket=$socket', tag: _tag);
      return -1;
    } else if (data.isEmpty) {
      return 0;
    }
    if (userUid == null) {
      return 0;
    }
    return 0;
  }

  @override
  Future<Uint8List?> read(int maxLen) async {
    _SocketCreator? socket = _socket;
    if (socket == null) {
      return null;
    }
    return null;
  }

  List<UserSocket> get sockets {
    _SocketCreator? socket = _socket;
    if (socket == null) {
      return [];
    }
    return socket.sockets;
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

  List<UserSocket> get sockets => _sockets;
  final List<UserSocket> _sockets = [];

  Future<bool> bind(String host, int port, [int timeout = 10000]) async {
    return await _bindSocket(host, port);
  }

  Future<bool> close([int timeout = 8000]) async {
    List<UserSocket> sockets = _sockets;
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
    UserSocket sock = UserSocket(socket);
    _sockets.add(sock);
    socket.listen(
      (data) => sock._caches.add(data),
      onError: (err) {},
      onDone: () {
        _removeSocket(sock);
      },
    );
  }

  Future<void> _removeSocket(UserSocket socket) async {
    _sockets.removeWhere((sock) => socket == sock);
    await socket.socket.close();
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
      _connecting = false;
      _connected = true;
      _closed = false;
      return true;
    } catch (e) {
      return false;
    }
  }
}

class UserSocket {
  final Socket socket;

  UserSocket(this.socket);

  List<Uint8List> get caches => _caches;
  final List<Uint8List> _caches = [];

  Uint8List? read() {
    var caches = _caches;
    if (caches.isEmpty) {
      return null;
    }

    return caches.removeAt(0);
  }

  Future<int> write(List<int> data) async {
    socket.add(data);
    return data.length;
  }

  void setUserUid(String userUid) => _userUid = userUid;
  String _userUid = '';
  String get userUid => _userUid;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is UserSocket && _userUid == other._userUid;
  }

  @override
  int get hashCode => Object.hash(socket, userUid);
}
