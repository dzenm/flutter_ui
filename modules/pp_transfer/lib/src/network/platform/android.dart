import 'dart:async';
import 'dart:convert';

import 'package:fbl/fbl.dart';
import 'package:fbl/src/config/notification.dart' as ln;
import 'package:fsm/fsm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pp_transfer/src/server/channel.dart';
import 'package:pp_transfer/src/server/service.dart';
import 'package:wifi_direct/wifi_direct.dart';

import '../../constant/names.dart';
import '../../socket/bs.dart';
import '../../socket/cs.dart';
import '../common/device.dart';
import '../common/im.dart';

///
/// Created by a0010 on 2025/2/26 11:28
///
class Android2Android extends Runner //
    with
        WifiDirectMixin,
        DeviceMixin,
        ClientMixin,
        ServerMixin,
        Logging
    implements
        NearbyServiceInterface {
  Android2Android() : super(Runner.intervalSlow) {
    // 注册监听
    _client
      ..register()
      ..setP2pConnectionListener(this)
      ..receiveConnectionStream().listen((value) {});
  }

  @override
  Future<bool> initialize() async {
    return (await _initialize()) == ServeStatus.completed;
  }

  @override
  Future<bool> connect(SocketAddress remote) async {
    return await _connectDevice(remote);
  }

  @override
  Future<void> dispose() async {
    await _clear();
  }

  @override
  Future<bool> process() async {
    return await receiveMsg();
  }
}

/// 处理 WiFi Direct
mixin WifiDirectMixin implements DeviceMixin, ClientMixin, ServerMixin, Logging, P2pConnectionListener {
  final WifiDirect _client = WifiDirect();

  /// 自己设备的信息
  WifiP2pDevice? get self => _self;
  WifiP2pDevice? _self;

  /// 获取扫描到附近的设备
  List<WifiP2pDevice> get devices => _devices;
  final List<WifiP2pDevice> _devices = [];

  /// 创建的群组信息
  WifiP2pConnection? get connection => _connection;
  WifiP2pConnection? _connection;

  ServeStatus get status => _status;
  ServeStatus _status = ServeStatus.none;

  void _setStatus(ServeStatus status) {
    _status = status;
    var nc = ln.NotificationCenter();
    nc.postNotification(WifiDirectNames.kStatusChanged, this, {
      'status': status,
    });
  }

  /// 初始化
  Future<ServeStatus> _initialize() async {
    // 1. 授权
    logInfo('1. 开始获取权限');
    // 判断GPS有没有打开
    _setStatus(ServeStatus.gPS);
    if (!await _client.isGPSEnabled()) {
      // 进入位置服务设置
      await _client.openLocationSettingsPage();
      return ServeStatus.gPS;
    }
    // 判断Wi-Fi服务有没有打开
    _setStatus(ServeStatus.wifi);
    if (!await _client.isWifiEnabled()) {
      // 进入Wi-Fi设置
      await _client.openWifiSettingsPage();
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
    if (!await _client.initialize()) {
      return ServeStatus.initialize;
    }

    // 3. 建立群组信息
    logInfo('3. 获取群组信息');
    _setStatus(ServeStatus.requestGroup);

    _setStatus(ServeStatus.discover);
    if (!await discoverPeers()) {
      return ServeStatus.discover;
    }

    logInfo('4. 准备好了');
    _setStatus(ServeStatus.completed);
    return ServeStatus.completed;
  }

  /// 请求连接权限
  Future<bool> _requestPermissions() async {
    int sdk = await _client.getPlatformSDKVersion();
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

  /// 发现设备
  Future<bool> discoverPeers() async {
    return await _client.discoverPeers();
  }

  /// 连接到 [remote] 设备
  Future<bool> _connectDevice(SocketAddress remote) async {
    List<WifiP2pDevice> devices = _devices.where((device) => remote.remoteAddress == device.deviceAddress).toList();
    if (devices.isEmpty) {
      return false;
    }
    WifiP2pDevice device = devices.first;
    switch (device.status) {
      case DeviceStatus.connected:
        return true;
      case DeviceStatus.invited:
        return false;
      case DeviceStatus.failed:
        return false;
      case DeviceStatus.available:
        break;
      case DeviceStatus.unavailable:
        return false;
    }
    clearAll();
    await disconnect();
    await close();
    logInfo('连接到群组：remote=${remote.remoteAddress}');
    await _client.connect(device.deviceAddress);
    return false;
  }

  /// 取消正在连接的设备
  Future<bool> cancelConnect() async {
    return _client.cancelConnect();
  }

  /// 离开群组，断开连接
  Future<bool> removeGroup() async {
    return _client.removeGroup();
  }

  /// 清除所有数据
  Future<void> _clear() async {
    // 取消注册监听
    await _client.unregister();
    await _client.removeGroup();
  }

  SocketAddress _mergeDevice(WifiP2pDevice device) {
    return WifiDirectAddress(
      isGroupOwner: device.isGroupOwner,
      status: device.status,
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
    List<SocketAddress> list = [];
    for (var peer in peers) {
      String deviceAddress = peer.deviceAddress;
      SocketAddress address = _mergeDevice(peer);
      list.add(address);
      var device = ServeDevice(address: address, device: peer);
      setDevice(deviceAddress, device);
    }
    var nc = ln.NotificationCenter();
    nc.postNotification(WifiDirectNames.kDevicesChanged, this, {
      'peers': list,
    });
  }

  @override
  void onConnectionInfoAvailable(WifiP2pConnection connection) async {
    logInfo('连接信息发送变化：info=${connection.toJson()}');
    if (connection.isConnected) {
      String host = connection.groupOwnerAddress.substring(1);
      int port = 1212;
      if (connection.groupFormed && connection.isGroupOwner) {
        if (server?.isConnected == false) {
          // 自己创建的群组且自己为群主
          Channel server = BSSocket(host: host, port: port);
          await server.connect();

          Channel client = CSSocket(host: host, port: port);
          if (await client.connect()) {
            String deviceAddress = connection.group?.owner?.deviceAddress ?? '';
            setSocket(deviceAddress, client);
          }
        }
      } else if (connection.groupFormed && !connection.isGroupOwner) {
        if (client?.isConnected == false) {
          // 加入到群组中的群成员
          Channel client = CSSocket(host: host, port: port);
          if (await client.connect()) {
            String deviceAddress = connection.group?.owner?.deviceAddress ?? '';
            setSocket(deviceAddress, client);
            client.write(utf8.encode('测试'));
          }
        }
      } else {
        // 不应该发生的事情
        return;
      }
    }
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

  @override
  void onDiscoverChanged(bool isDiscover) {
    logInfo('搜索附近的设备：isDiscover=$isDiscover');
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
    required DeviceStatus status,
    required String deviceName,
    required String localAddress,
    required String remoteAddress,
  })  : _isGroupOwner = isGroupOwner,
        _status = status,
        _deviceName = deviceName,
        _localAddress = localAddress,
        _remoteAddress = remoteAddress;

  @override
  bool get isGroupOwner => _isGroupOwner;
  final bool _isGroupOwner;

  @override
  DeviceStatus get status => _status;
  final DeviceStatus _status;

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
