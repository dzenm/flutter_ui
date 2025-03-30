import 'dart:async';
import 'dart:convert';

import 'package:fbl/fbl.dart';
import 'package:fbl/src/config/notification.dart' as ln;
import 'package:permission_handler/permission_handler.dart';
import 'package:pp_transfer/src/server/service.dart';
import 'package:wifi_direct/wifi_direct.dart';

import '../../constant/names.dart';
import '../common/device.dart';
import '../common/im.dart';
import '../common/message.dart';

///
/// Created by a0010 on 2025/2/26 11:28
///
class Android2Android //
    with
        WifiDirectMixin,
        DeviceMixin,
        Logging
    implements
        NearbyServiceInterface {
  Android2Android() {
    // 注册监听
    _client
      ..register()
      ..setP2pConnectionListener(this)
      ..receiveConnectionStream().listen((value) {});
    _manager.start();
    _server.start();
  }

  @override
  Future<bool> initialize({bool isGroupOwner = true}) async {
    return (await _initialize(isGroupOwner: isGroupOwner)) == ServeStatus.completed;
  }

  @override
  void addMessage(IMessage message) {
    if (message is Message) {
      _manager.addData(message);
    }
  }

  @override
  Future<bool> connect(SocketAddress remote) async {
    return await _connectDevice(remote);
  }

  @override
  Future<void> dispose() async {
    await _clear();
  }
}

/// 处理 WiFi Direct
mixin WifiDirectMixin implements DeviceMixin, Logging, P2pConnectionListener {
  final WifiDirect _client = WifiDirect();
  final ClientManager _manager = ClientManager();
  final ServerManager _server = ServerManager();

  /// 自己设备的信息
  WifiP2pDevice? get self => _self;
  WifiP2pDevice? _self;

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

  bool _isInit = false;

  /// 初始化
  Future<ServeStatus> _initialize({bool isGroupOwner = true}) async {
    logInfo('1. 检测WiFi是否打开');
    // 1. WiFi开启状态
    if (!_isEnabledWifiDirect) {
      return ServeStatus.disableWifi;
    }
    // 2. 授权
    logInfo('2. 开始获取权限');
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

    if (!_isInit) {
      _setStatus(ServeStatus.initialize);
      if (!await _client.initialize()) {
        return ServeStatus.initialize;
      }
      _isInit = true;
    }

    if (isGroupOwner) {
      // 3. 建立群组信息
      logInfo('3. 获取群组信息');
      _setStatus(ServeStatus.requestGroup);
      WifiP2pGroup? group = await _client.requestGroup();
      if (group == null) {
        _setStatus(ServeStatus.createGroup);
        if (!await _client.createGroup()) {
          return ServeStatus.createGroup;
        }
        group = await _client.requestGroup();
      }
    } else {
      // 3. 开始发现附近的设备
      logInfo('3. 开始发现附近的设备');
      _setStatus(ServeStatus.discover);
      if (!await discoverPeers()) {
        return ServeStatus.discover;
      }
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
    await removeGroup();
    WifiP2pDevice? device = get(remote.remoteAddress);
    if (device == null) {
      return false;
    }
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
    if (await _client.connect(device.deviceAddress)) {
      logDebug('连接到群组：remote=${remote.remoteAddress} 成功');
      _manager.setConnecting();
      return true;
    }
    logError('连接到群组：remote=${remote.remoteAddress} 失败');
    return false;
  }

  /// 取消正在连接的设备
  Future<bool> cancelConnect() async {
    return _client.cancelConnect();
  }

  /// 成群组拥有者
  Future<bool> becomeGroupOwner() async {
    WifiP2pGroup? group = await _client.requestGroup();
    if (group == null) {
      _setStatus(ServeStatus.createGroup);
      if (!await _client.createGroup()) {
        return false;
      }
      group = await _client.requestGroup();
    }
    return true;
  }

  /// 离开群组，断开连接
  Future<bool> removeGroup() async {
    return _client.removeGroup();
  }

  /// 清除所有数据
  Future<void> _clear() async {
    // 取消注册监听
    await _exitGroup();
    await _client.unregister();
  }

  Future<void> _exitGroup() async {
    await _manager.close();
    await _manager.stop();
    await _server.close();
    await _server.stop();
    await _client.removeGroup();
  }

  bool _isEnabledWifiDirect = false;

  @override
  void onP2pState(bool enabled) {
    logDebug('设备的 Wi-Fi Direct 启用或禁用状态：enabled=$enabled');
    _isEnabledWifiDirect = enabled;
  }

  @override
  void onPeersAvailable(List<WifiP2pDevice> peers) {
    logDebug('获取更新的对等点列表：peers=${jsonEncode(peers)}');
    for (var peer in peers) {
      String deviceAddress = peer.deviceAddress;
      setDevice(deviceAddress, peer);
    }
    var nc = ln.NotificationCenter();
    nc.postNotification(WifiDirectNames.kDevicesChanged, this, {
      'peers': peers,
    });
  }

  @override
  void onConnectionInfoAvailable(WifiP2pConnection connection) async {
    if (jsonEncode(connection) == jsonEncode(_connection)) {
      return;
    }
    _connection = connection;
    var nc = ln.NotificationCenter();
    nc.postNotification(WifiDirectNames.kConnectionChanged, this, {
      'connection': connection,
    });
    logDebug('设备的 Wi-Fi 连接状态改变：info=${connection.toJson()}');
    if (!connection.isConnected) {
      logInfo('连接已断开');
      await discoverPeers();
      return;
    }
    if (!connection.groupFormed) {
      logInfo('群组未建立');
      return;
    }
    WifiP2pGroup? group = connection.group;
    if (group == null) {
      logInfo('群组信息为空');
      return;
    }
    WifiP2pDevice? owner = group.owner;
    if (owner == null) {
      logInfo('群主设备信息为空');
      return;
    }
    bool isGroupOwner = group.isGroupOwner;
    String text = isGroupOwner ? '（我是群主）' : '（我是群成员）';
    if (_manager.isConnected) {
      logInfo('群组已建立$text，已连接无需重复连接');
      return;
    }
    String host = connection.groupOwnerAddress.substring(1);
    int port = 2121;

    // 启动服务器
    if (isGroupOwner) {
      await _server.listen(host, port);
      logInfo('群组已建立$text，服务器已启动');
    }

    // 启动客户端
    bool result = await _manager.connectSocket(host, port);
    logInfo('群组已建立$text，连接Socket${result ? '成功' : '失败'}');
    if (result) {
      _manager.addData(AuthMessage(
        sessionUid: StrUtil.generateUid(),
        userUid: self!.deviceAddress,
      ));
      logInfo('发送登录认证消息');
    }
  }

  @override
  void onSelfP2pChanged(WifiP2pDevice device) {
    logDebug('设备的 Wi-Fi 状态变化：device=${device.toJson()}');
    _self = device;
    var nc = ln.NotificationCenter();
    nc.postNotification(WifiDirectNames.kSelfChanged, this, {
      'self': device,
    });
  }

  @override
  void onDiscoverChanged(bool isDiscover) {
    logDebug('搜索附近的设备：isDiscover=$isDiscover');
  }
}

enum ServeStatus {
  none, // 初始状态
  disableWifi, // WiFi未打开
  gPS, // 检测GPS权限
  wifi, // 检测Wi-Fi
  nearbyOrLocationPermission, // 检测附近的设备或位置权限
  grantedPermission, // 授权
  initialize, // 初始化
  requestGroup, // 发现设备
  createGroup, // 发现设备
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
