import 'package:pp_transfer/pp_transfer.dart';

///
/// Created by a0010 on 2025/2/26 11:04
///
abstract interface class NearbyService {

  /// 初始化
  /// [return] true=初始化成功；false=初始化失败；
  Future<bool> initialize();

  /// 扫描设备
  /// [return] 扫描的设备信息
  Future<bool> discoverDevices();

  /// 连接设备
  /// [remote] 连接的设备地址
  /// [message] 发送的消息数据
  /// [return] true=连接设备成功；false=连接设备失败；
  Future<bool> send(SocketAddress remote, IMessage message);

  /// 清除信息
  Future<void> dispose();
}

enum ServiceFlag {
  none, // 初始状态
  disableWifi, // WiFi未打开
  gPS, // 检测GPS权限
  wifi, // 检测Wi-Fi
  nearbyOrLocationPermission, // 检测附近的设备或位置权限
  grantedPermission, // 授权
  initialize, // 初始化
  completed, // 初始化完成
}

enum TransitFlag {
  none, // 未初始化
  pair, // 配对成功
  prepare, // 已配对等待传输
  connecting, // 正在连接socket
  connected, // 连接socket成功
  transiting, // 正在传输中
}

enum StepFlag {
  none,
  disableWifi, // Wi-Fi未打开
  enableWifi, // Wi-Fi已打开
  enableGPS, // GPS未打开
  disableGPS, // GPS已打开
  enablePermission, // 检测附近的设备或位置权限未打开
  disablePermission, // 检测附近的设备或位置权限已打开
  initialize, // 初始化
  discover, // 发现设备
  unpair, // 未配对
  pairing, // 配对中
  paired, // 已配对
  preparing, // 预备中
  connecting, // 正在连接Socket
  connected, // 已连接Socket
  transiting, // 正在传输中
}

abstract interface class NearbyServiceInterface {
  /// 初始化
  /// [return] true=初始化成功，false=初始化失败
  Future<bool> initialize();

  /// 添加发送的数据
  /// [message] 待发送的数据
  void addMessage(IMessage message);

  /// 连接设备
  /// [remote] 连接的设备地址
  /// [return] true=连接设备成功；false=连接设备失败；
  Future<bool> connect(SocketAddress remote);

  /// 清除信息
  Future<void> dispose();
}

abstract interface class IMessage {}

/// 连接的Socket地址
abstract interface class SocketAddress {
  /// 是否是群组拥有者
  bool get isGroupOwner;

  /// 设备状态
  DeviceStatus get status;

  /// 设备名称
  String get deviceName;

  /// 本机地址
  String get localAddress => '';

  /// 服务器地址
  String get remoteAddress => '';
}
