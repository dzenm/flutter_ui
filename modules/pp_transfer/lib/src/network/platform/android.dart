import 'dart:async';
import 'dart:convert';

import 'package:fbl/fbl.dart';
import 'package:fbl/src/config/notification.dart' as ln;
import 'package:permission_handler/permission_handler.dart';
import 'package:pp_transfer/src/network/service/connection.dart';
import 'package:pp_transfer/src/network/service/service.dart';
import 'package:wifi_direct/wifi_direct.dart';

import '../names.dart';

///
/// Created by a0010 on 2025/2/26 11:28
///
class Android2Android with Logging implements NearbyServiceInterface, Connection, P2pConnectionListener {
  final WifiDirect client = WifiDirect();

  Android2Android() {
    // 注册监听
    client
      ..register()
      ..setP2pConnectionListener(this)
      ..receiveConnectionStream().listen((value) {});
  }

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
  WifiP2pConnection? get connection => _connection;
  WifiP2pConnection? _connection;

  @override
  Future<bool> initialize() async {
    return (await _initialize()) == ServeStatus.completed;
  }

  void _setStatus(ServeStatus status) {
    _status = status;
    var nc = ln.NotificationCenter();
    nc.postNotification(WifiDirectNames.kStatusChanged, this, {
      'status': status,
    });
  }

  ServeStatus _status = ServeStatus.none;

  ServeStatus get status => _status;

  /// 初始化
  Future<ServeStatus> _initialize() async {
    // 1. 授权
    logInfo('1. 开始获取权限');
    // 判断GPS有没有打开
    _setStatus(ServeStatus.gPS);
    if (!await client.isGPSEnabled()) {
      // 进入位置服务设置
      await client.openLocationSettingsPage();
      return ServeStatus.gPS;
    }
    // 判断Wi-Fi服务有没有打开
    _setStatus(ServeStatus.wifi);
    if (!await client.isWifiEnabled()) {
      // 进入Wi-Fi设置
      await client.openWifiSettingsPage();
      return ServeStatus.wifi;
    }
    // 请求位置权限和附近的设备权限
    _setStatus(ServeStatus.nearbyOrLocationPermission);
    if (!await _requestPermissions()) {
      return ServeStatus.nearbyOrLocationPermission;
    }

    // 2. 开始初始化信息
    logInfo('2. 开始初始化信息');
    _setStatus(ServeStatus.initialize);
    if (!await client.initialize()) {
      return ServeStatus.initialize;
    }

    // 3. 建立群组信息
    logInfo('3. 获取群组信息');
    _setStatus(ServeStatus.requestGroup);

    _setStatus(ServeStatus.discover);
    if (!await client.discoverPeers()) {
      return ServeStatus.discover;
    }

    logInfo('4. 准备好了');
    _isPrepare = true;
    _setStatus(ServeStatus.completed);
    return ServeStatus.completed;
  }

  /// 请求连接权限
  Future<bool> _requestPermissions() async {
    int sdk = await client.getPlatformSDKVersion();
    if (sdk >= 33) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.nearbyWifiDevices,
      ].request();
      return statuses[Permission.location] == PermissionStatus.granted && //
          statuses[Permission.nearbyWifiDevices] == PermissionStatus.granted;
    }
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
    ].request();
    return statuses[Permission.location] == PermissionStatus.granted;
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
    // 取消注册监听
    await client.unregister();
    await client.removeGroup();
  }

  SocketAddress _mergeDevice(WifiP2pDevice device) {
    return WifiDirectAddress(
      isGroupOwner: device.isGroupOwner,
      isConnected: device.isConnected,
      deviceName: device.deviceName,
      localAddress: '',
      remoteAddress: device.deviceAddress,
    );
  }

  @override
  void onP2pState(bool enabled) {
    logInfo('P2P状态改变：enabled=$enabled');
  }

  @override
  void onPeersAvailable(List<WifiP2pDevice> peers) {
    logInfo('获取到可用的设备：peers=${jsonEncode(peers)}');
    _devices.clear();
    _devices.addAll(peers);
    var list = peers.map((device) => _mergeDevice(device)).toList();
    var nc = ln.NotificationCenter();
    nc.postNotification(WifiDirectNames.kDevicesChanged, this, {
      'peers': list,
    });
  }

  @override
  void onConnectionInfoAvailable(WifiP2pConnection info) {
    logInfo('连接信息发送变化：info=${info.toJson()}');
  }

  @override
  void onSelfP2pChanged(WifiP2pDevice device) {
    logInfo('自己的设备信息发送变化：device=${device.toJson()}');
    _self = device;
    var nc = ln.NotificationCenter();
    nc.postNotification(WifiDirectNames.kSelfChanged, this, {
      'self': device,
    });
  }
}

enum ServeStatus {
  none, // 初始状态
  gPS, // 检测GPS权限
  wifi, // 检测Wi-Fi
  nearbyOrLocationPermission, // 检测附近的设备或位置权限
  grantedPermission, // 授权
  initialize, // 初始化
  requestGroup, // 获取群组
  discover, // 发现设备
  completed, // 初始化完成
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
