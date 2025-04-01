import 'dart:math';
import 'dart:typed_data';

import 'package:fbl/fbl.dart';
import 'package:fbl/src/config/notification.dart' as ln;
import 'package:fsm/fsm.dart';
import 'package:pp_transfer/pp_transfer.dart';

import '../../server/channel.dart';
import '../../server/connection.dart';
import '../../socket/client.dart';
import '../../socket/owner.dart';
import '../../socket/server.dart';
import '../queue/queue.dart';

const int kExpires = 16 * 1000; // 16 seconds

///
/// 建立连接，就可以使用套接字在设备之间传输数据。传输数据的基本步骤如下：
///
/// 创建一个ServerSocket。此套接字等待来自指定端口上的客户端的连接并阻塞直到发生连接，因此请在后台线程中执行此操作。
/// 创建客户端Socket。客户端使用服务器套接字的 IP 地址和端口连接到服务器设备。
/// 从客户端向服务器发送数据。当客户端套接字成功连接到服务器套接字时，就可以用字节流将数据从客户端发送到服务器。
/// 服务器套接字等待客户端连接（使用accept()方法）。此调用会阻塞，直到客户端连接为止，因此调用此方法是另一个线程。
/// 连接发生时，服务器设备可以从客户端接收数据。使用此数据执行任何操作，例如将其保存到文件或呈现给用户。
///

///=========================== 客户端 ===========================
/// Socket连接处理
abstract class SocketManager extends Runner with Logging {
  SocketManager(super.millis);

  bool get isConnecting => _isConnecting;
  bool _isConnecting = false; // 是否正在连接中
  void setConnecting() => _isConnecting = true;

  bool get isConnected => _isConnected;
  bool _isConnected = false; // 是否连接成功

  Channel? _socket; // 当前连接的socket

  /// 连接socket
  Future<bool> connectSocket(
    String host,
    int port, {
    SocketFlag flag = SocketFlag.client,
  }) async {
    if (_isConnecting) return false;
    _isConnecting = true;
    Channel? socket = _socket;
    if (socket != null) {
      if (socket.isConnected) {
        return true;
      }
      return false;
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
      logDebug('连接到 `$host:$port` 成功');

      await _setSocket(socket);
      return true;
    }
    logError('连接到 `$host:$port` 失败');
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
    bool connected = socket != null;
    _isConnecting = false;
    _isConnected = connected;
  }

  Future<void> close() async {
    await _setSocket(null);
    _isConnecting = false;
    _isConnected = false;
  }
}

/// 发送方
mixin SenderMixin on SocketManager implements Sender {
  final IMessageQueue<Message> _queue = IMessageQueue(); // 发送消息的队列

  /// 等待发送的数据
  @override
  void addData(IMessage message) {
    if (message is Message) {
      _queue.add(message);
    }
  }

  DateTime? get lastSentTime => _lastSentTime;
  DateTime? _lastSentTime;

  bool isSentRecently(DateTime now) {
    int last = _lastSentTime?.millisecondsSinceEpoch ?? 0;
    return now.millisecondsSinceEpoch <= last + kExpires;
  }

  /// 发送数据
  Future<bool> _sendData() async {
    Channel? socket = _socket;
    if (socket == null) {
      return false;
    }
    if (!_isConnected) {
      logError('Socket channel lost: socket=$socket');
      return false;
    }
    var queue = _queue;
    var message = queue.poll();
    if (message == null) {
      return false;
    }
    List<int> data = mc.encode(message);
    if ((await _doSend(data)) > 0) {
      return true;
    }
    logError('发送的数据失败');
    return false;
  }

  Future<int> _doSend(List<int> data) async {
    Channel? socket = _socket;
    if (socket == null || !_isConnected) {
      logError('Socket channel lost: socket=$socket');
      return -1;
    }

    // 分块发送
    List<int> bytes = List.castFrom(data);
    int start = 0, sentLen = 0, senCount = 0;
    while (start < bytes.length) {
      int len = min(start + 1024, bytes.length);
      sentLen += await socket.write(bytes.sublist(start, len));
      start = len;
      senCount++;
    }

    if (data.length > sentLen) {
      logError('发送失败：data=${data.length}，sentLen=$sentLen');
      return -1;
    } else if (data.length < sentLen) {
      logError('It should not happen');
      return -1;
    }
    logDebug('发送的数据长度：count=$senCount, sentLen=$sentLen');
    if (sentLen > 0) {
      // update sent time
      _lastSentTime = DateTime.now();
    }
    return sentLen;
  }
}

/// 接收方
mixin ReceiverMixin on SocketManager implements Receiver {
  List<int> _caches = [];

  DateTime? get lastReceivedTime => _lastReceivedTime;
  DateTime? _lastReceivedTime;

  bool isReceivedRecently(DateTime now) {
    int last = _lastReceivedTime?.millisecondsSinceEpoch ?? 0;
    return now.millisecondsSinceEpoch <= last + kExpires;
  }

  bool isNotReceivedLongTimeAgo(DateTime now) {
    int last = _lastReceivedTime?.millisecondsSinceEpoch ?? 0;
    return now.millisecondsSinceEpoch > last + (kExpires << 3);
  }

  /// 接收数据
  Future<bool> _receiveData() async {
    Channel? socket = _socket;
    if (socket == null) {
      return false;
    }
    if (!_isConnected) {
      logError('Socket channel lost: socket=$socket');
      return false;
    }
    Uint8List? data = await socket.read(1024);
    if (data == null) {
      return false;
    }
    if (data.isEmpty) {
      return false;
    }
    _lastReceivedTime = DateTime.now(); // update received time

    Message? message = onDistributeMessage(data);
    if (message != null) {
      receiveData(message);
    }
    return true;
  }

  final VerifyPacketData _verify = VerifyPacketData();

  Message? onDistributeMessage(Uint8List data) {
    List<int> caches = _caches;
    caches.addAll(data);
    if (!_verify.isFull(caches)) {
      return null;
    }
    int singleByte = kHeaderLen + _verify.length;
    List<int> bytes = caches.sublist(0, singleByte); // 获取单条消息数据
    _caches = caches.sublist(singleByte); // 删除解析成功的数据

    Message message = mc.decode(bytes); // 解析单条数据
    return message;
  }

  @override
  void receiveData(IMessage message) {
    if (message is Message) {
      logDebug('接收的数据：text=${message.toDebugJson()}');
      var nc = ln.NotificationCenter();
      nc.postNotification(WifiDirectNames.kReceiveTextData, this, {
        'text': message,
      });
    }
  }
}

/// 客户端Socket
class ClientManager extends SocketManager with SenderMixin, ReceiverMixin {
  ClientManager() : super(Runner.intervalSlow);

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

///=========================== 服务端 ===========================

/// 服务端Socket
class ServerManager extends Runner with Logging {
  ServerChannel? _server;

  ServerManager() : super(Runner.intervalSlow);

  Future<bool> listen(String host, int port) async {
    ServerChannel? server = _server;
    if (server != null && (server.isConnected || server.isConnecting)) {
      return true;
    }
    server = ServerChannel(host: host, port: port);
    await server.connect();
    _server = server;
    logInfo('Server服务已创建');
    return true;
  }

  Future<void> close() async {
    await _server?.close();
    _server = null;
  }

  List<int> _caches = [];

  Future<bool> transformAll() async {
    ServerChannel? server = _server;
    if (server == null) {
      return false;
    }
    int count = 0;
    for (var item in server.sockets) {
      if (await transform(item)) {
        count++;
      }
    }
    return count > 0;
  }

  final VerifyPacketData _verify = VerifyPacketData();

  Future<bool> transform(UserSocket socket) async {
    ServerChannel? server = _server;
    if (server == null) {
      return false;
    }

    Uint8List? data = socket.read();
    if (data == null) {
      return false;
    }
    if (data.isEmpty) {
      return false;
    }
    List<int> caches = _caches;
    caches.addAll(data);
    if (!_verify.isFull(caches)) {
      return false;
    }
    int singleByte = kHeaderLen + _verify.length;
    List<int> bytes = caches.sublist(0, singleByte); // 获取单条消息数据
    _caches = caches.sublist(singleByte); // 删除解析成功的数据

    Message message = mc.decode(bytes); // 解析单条数据
    if (message is AuthMessage) {
      String userUid = message.userUid;
      socket.setUserUid(userUid);
      logDebug('用户 `$userUid` 已登录成功');
    } else if (message is ChatMessage) {
      String? sendUid = message.sendUid;
      String? receiveUid = message.receiveUid;
      logDebug('接收到用户 `$sendUid` 的消息：${message.toJson()}');

      for (var item in server.sockets) {
        String userUid = item.userUid;
        if (sendUid == userUid) {
          continue;
        }
        if (receiveUid.isEmpty) {
          item.write(data);
          logDebug('转发给所有用户，当前转发的用户为 `$userUid` 的消息：${message.toJson()}');
        } else if (receiveUid == userUid) {
          item.write(data);
          logDebug('转发给单用户，当前转发的用户为 `$userUid` 的消息：${message.toJson()}');
          break;
        } else {
          continue;
        }
      }
    } else {
      logInfo('It not should happen');
    }
    return true;
  }

  @override
  Future<bool> process() async {
    return await transformAll();
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
