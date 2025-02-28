///
/// Created by a0010 on 2025/2/26 11:04
///
abstract class NearbyService {
  /// 请求权限
  Future<bool> requestPermission();

  /// 初始化
  Future<bool> initialize();

  /// 连接
  Future<bool> connect();

  /// 传输
  Future<bool> transfer();
}

/// 连接的地址
abstract interface class Address {
  String get localAddress;
  String get remoteAddress;
}

/// 连接的Socket地址
abstract class SocketAddress implements Address {
  @override
  String get localAddress => '';
  @override
  String get remoteAddress => '';
}
