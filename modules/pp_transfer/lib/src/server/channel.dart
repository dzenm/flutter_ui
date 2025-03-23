import 'dart:typed_data';

abstract class Channel {
  bool get isClosed;

  bool get isConnecting;

  bool get isConnected;

  bool get isAlive;

  Future<bool> connect();

  Future<int> write(List<int> data);

  Future<Uint8List?> read(int maxLen);

  Future<void> close();
}
