import 'dart:async';

import 'package:fbl/fbl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pp_transfer/src/network/service/connection.dart';
import 'package:pp_transfer/src/network/service/service.dart';
import 'package:wifi_direct/wifi_direct.dart';

///
/// Created by a0010 on 2025/2/26 11:28
///
class Android2Android with Logging implements NearbyServiceInterface, Connection, P2pConnectionListener {
  final WifiDirect client = WifiDirect();

  void setOnDeviceListener(DeviceListener listener) {
    _listener = listener;
  }
  DeviceListener? _listener;

  @override
  bool get isPrepare => _isPrepare;
  bool _isPrepare = false;

  @override
  bool get isConnected => _isConnected;
  bool _isConnected = false;

  @override
  bool get isTransiting => _isTransiting;
  final bool _isTransiting = false;

  /// 自己设备的信息
  WifiP2pDevice? get self => _self;
  WifiP2pDevice? _self;

  /// 获取扫描到附近的设备
  List<WifiP2pDevice> get devices => _devices;
  final List<WifiP2pDevice> _devices = [];

  /// 创建的群组信息
  WifiP2pInfo? get wifi => _wifi;
  WifiP2pInfo? _wifi;

  /// 注册监听/取消注册监听
  void register() => client.register();
  void unregister() => client.unregister();

  @override
  Future<ServeStatus> initialize() async {
    // 1. 授权
    logInfo('1. 开始获取权限');
    ServeStatus status = await _checkPermission();
    if (status != ServeStatus.grantedPermission) {
      return status;
    }

    // 2. 开始初始化信息
    logInfo('2. 开始初始化信息');
    if (!await client.initialize()) {
      return ServeStatus.initializeError;
    }

    await client.register();
    // 3. 设置监听回调
    logInfo('3. 设置监听回调');
    client.setP2pConnectionListener(this);
    client.receiveConnectionStream();

    // 4. 建立群组信息
    logInfo('4. 建立群组信息');
    WifiP2pGroup? group = await client.requestGroup() ;
    if (group == null) {
      if (!await client.createGroup()) {
        return ServeStatus.createGroupError;
      }
    }

    logInfo('5. 准备好了');
    _isPrepare = true;
    return ServeStatus.initialize;
  }

  /// 检查权限
  Future<ServeStatus> _checkPermission() async {
    // 判断位置服务有没有打开
    if (await client.isGPSEnabled()) {
      // 判断Wi-Fi服务有没有打开
      if (await client.isWifiEnabled()) {
        // 请求权限
        bool res = await _requestPermissions();
        if (res) {
          return ServeStatus.grantedPermission;
        }
        return ServeStatus.nearbyOrLocationPermissionError;
      } else {
        // 进入Wi-Fi设置
        await client.openWifiSettingsPage();
      }
    } else {
      // 进入位置服务设置
      await client.openLocationSettingsPage();
    }
    return ServeStatus.wifiOrGPSPermissionError;
  }

  /// 请求连接权限
  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.nearbyWifiDevices,
    ].request();
    return statuses[Permission.location] == PermissionStatus.granted && //
        statuses[Permission.nearbyWifiDevices] == PermissionStatus.granted;
  }

  @override
  Future<bool> discoverDevices() async {
    logInfo('扫描附近的设备');
    return await client.discoverPeers();
  }

  @override
  Future<bool> connect(SocketAddress remote) async {
    logInfo('连接到群组：remote=${remote.remoteAddress}');
    if (await client.connect(remote.remoteAddress)) {
      _isConnected = true;
    }
    return false;
  }

  @override
  Future<void> dispose() async {
  }

  List<SocketAddress> _merge(List<WifiP2pDevice> list) {
    return list.map((device) {
      return WifiDirectAddress(
        isGroupOwner: device.isGroupOwner,
        isConnected: device.isConnected,
        deviceName: device.deviceName,
        localAddress: '',
        remoteAddress: device.deviceAddress,
      );
    }).toList();
  }

  @override
  void onP2pState(bool enabled) {
    logInfo('P2P状态改变：enabled=$enabled');
  }

  @override
  void onPeersAvailable(List<WifiP2pDevice> peers) {
    logInfo('获取到可用的设备：peers=${peers.length}');
    _devices.clear();
    _devices.addAll(peers);
  }

  @override
  void onConnectionInfoAvailable(WifiP2pInfo info) {
    logInfo('连接信息发送变化：info=${info.toJson()}');
  }

  @override
  void onDisconnected() {
    logInfo('已断开连接');
    _isConnected = false;
  }

  @override
  void onSelfP2pChanged(WifiP2pDevice device) {
    logInfo('自己的设备信息发送变化：device=${device.toJson()}');
    _self = device;
  }
}

class WifiDirectAddress implements SocketAddress {
  WifiDirectAddress({
    required bool isGroupOwner,
    required bool isConnected,
    required String deviceName,
    required String localAddress,
    required String remoteAddress,
  })  : _isGroupOwner = isGroupOwner,
        _isConnected = isConnected,
        _deviceName = deviceName,
        _localAddress = localAddress,
        _remoteAddress = remoteAddress;

  @override
  bool get isGroupOwner => _isGroupOwner;
  final bool _isGroupOwner;

  @override
  bool get isConnected => _isConnected;
  final bool _isConnected;

  @override
  String get deviceName => _deviceName;
  final String _deviceName;

  @override
  String get localAddress => _localAddress;
  final String _localAddress;

  @override
  String get remoteAddress => _remoteAddress;
  final String _remoteAddress;
}

