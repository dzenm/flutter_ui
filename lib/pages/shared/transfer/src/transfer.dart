///
/// Created by a0010 on 2025/1/25 13:07
/// 传输
abstract interface class Transfer {}

/// Socket传输
abstract interface class SocketTransfer implements Transfer {}

/// 流传输
abstract interface class StreamTransfer implements SocketTransfer {
  List<int> get data;
}

/// 角色
abstract interface class Role {}

/// 发送方
abstract interface class Sender extends Role {
  List<int> create();
}

/// 接收方
abstract interface class Receiver extends Role {
  void distribute(List<int> data);
}

/// 字节传输
abstract class ByteTransfer implements StreamTransfer {}

/// 字符传输
abstract class BufferTransfer implements StreamTransfer {}
