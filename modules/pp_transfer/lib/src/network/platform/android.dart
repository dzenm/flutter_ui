import 'dart:async';

import 'package:fbl/fbl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pp_transfer/src/network/service/connection.dart';
import 'package:pp_transfer/src/network/service/service.dart';
import 'package:wifi_direct/wifi_direct.dart';

///
/// Created by a0010 on 2025/2/26 11:28
///
class Android2Android with Logging implements NearbyService, Connection {
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

  @override
  Future<bool> requestPermission() async {
    String result = await _checkPermission();
    if (result.isEmpty) {
      _isPrepare = true;
      return true;
    }
    return false;
  }

  /// 检查权限
  Future<String> _checkPermission() async {
    // 判断位置服务有没有打开
    if (await client.isGPSEnabled()) {
      // 判断Wi-Fi服务有没有打开
      if (await client.isWifiEnabled()) {
        // 请求权限
        bool res = await _requestPermissions();
        if (res) {
          return '';
        }
        return '未打开附近的设备或位置权限';
      } else {
        // 进入Wi-Fi设置
        await client.openWifiSettingsPage();
      }
    } else {
      // 进入位置服务设置
      await client.openLocationSettingsPage();
    }
    return '未打开GPS权限';
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

  StreamSubscription<List<WifiP2pDevice>>? _discoverPeersSubscription;
  StreamSubscription<WifiP2pInfo>? _wifiSubscription;

  /// 获取扫描到附近的设备
  List<WifiP2pDevice> get device => _devices;
  final List<WifiP2pDevice> _devices = [];

  /// 创建的群组信息
  WifiP2pInfo? get wifi => _wifi;
  WifiP2pInfo? _wifi;
  
  bool _isRegister = false;

  @override
  Future<bool> initialize() async {
    if (_isRegister) {
      await client.unregister();
      _isRegister = false;
    }
    if (!await client.initialize()) return false;
    if (!await client.register()) return false;
    _isRegister = true;
    client.getConnectionStream().listen((data) {
      logInfo('接收到的数据：data');
    });
    // 获取群组信息
    WifiP2pGroup? group = await client.requestGroup();
    if (group == null) {
      if (await client.createGroup()) {
        return true;
      }
      return false;
    }
    return true;
  }

  @override
  Future<List<SocketAddress>> discoverDevices() async {
    // 移除自身创建的群组
    await client.disconnect();
    await client.removeGroup();
    await client.discover();
    return [];
  }

  @override
  Future<bool> connect(SocketAddress remote) async {
    if (await client.connect(remote.remoteAddress)) {
      _isConnected = true;
    }
    return false;
  }

  @override
  Future<void> dispose() async {
    await _discoverPeersSubscription?.cancel();
    await _wifiSubscription?.cancel();
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
