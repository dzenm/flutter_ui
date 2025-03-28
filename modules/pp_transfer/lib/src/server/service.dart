import 'dart:typed_data';

import 'package:pp_transfer/pp_transfer.dart';

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

abstract interface class IMessage {

}

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
