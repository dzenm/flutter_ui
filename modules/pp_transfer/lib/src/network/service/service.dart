///
/// Created by a0010 on 2025/2/26 11:04
///
abstract interface class NearbyService {
  /// 请求权限
  /// [return] true=已获取权限；false=未获取权限；
  Future<bool> requestPermission();

  /// 初始化
  /// [return] true=初始化成功；false=初始化失败；
  Future<bool> initialize();

  /// 扫描设备
  /// [return] 扫描的设备信息
  Future<List<SocketAddress>> discoverDevices();

  /// 连接设备
  /// [remote] 连接的设备地址
  /// [return] true=连接设备成功；false=连接设备失败；
  Future<bool> connect(SocketAddress remote);

  /// 清除信息
  Future<void> dispose();
}

abstract interface class NearbyServiceInterface {

  /// 初始化
  /// [return] @see [WifiError]
  Future<ServeStatus> initialize();

  /// 扫描设备
  /// [return] 扫描的设备信息
  Future<bool> discoverDevices();

  /// 连接设备
  /// [remote] 连接的设备地址
  /// [return] true=连接设备成功；false=连接设备失败；
  Future<bool> connect(SocketAddress remote);

  /// 清除信息
  Future<void> dispose();
}

enum ServeStatus {
  none, // 初始状态
  nearbyOrLocationPermissionError, // 附近的设备或位置权限未打开
  wifiOrGPSPermissionError, // Wi-Fi或GPS权限未打开
  grantedPermission, // 已授权
  initializeError, // 初始化错误
  createGroupError, // 创建群组错误
  initialize, // 初始化完成
}

abstract interface class DeviceListener {
  void onListen(List<SocketAddress> addresses);
}

/// 连接的Socket地址
abstract interface class SocketAddress {
  /// 是否是群组拥有者
  bool get isGroupOwner;
  /// 是否连接成功
  bool get isConnected;
  /// 设备名称
  String get deviceName;
  /// 本机地址
  String get localAddress => '';
  /// 服务器地址
  String get remoteAddress => '';
}
