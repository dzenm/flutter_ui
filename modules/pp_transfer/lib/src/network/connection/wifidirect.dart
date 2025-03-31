import 'dart:convert';

import 'package:fbl/fbl.dart';
import 'package:fbl/src/config/notification.dart' as ln;
import 'package:fsm/fsm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_direct/wifi_direct.dart';

import '../../constant/names.dart';
import '../../server/connection.dart';
import '../../server/service.dart';
import '../common/im.dart';

///
/// Created by a0010 on 2025/3/31 10:02
///
class AndroidToAndroid implements NearbyService, Connection {
  @override
  bool get isPair => throw UnimplementedError();

  @override
  bool get isConnected => throw UnimplementedError();

  @override
  bool get isClosed => throw UnimplementedError();

  @override
  bool get isConnecting => throw UnimplementedError();

  @override
  bool get isAlive => throw UnimplementedError();

  @override
  bool get isTransiting => throw UnimplementedError();

  @override
  Future<bool> initialize() async {
    return true;
  }

  @override
  Future<bool> discoverDevices() async {
    return true;
  }

  @override
  Future<bool> send(SocketAddress remote, IMessage message) async {
    return true;
  }

  @override
  Future<void> dispose() {
    throw UnimplementedError();
  }
}

abstract class WifiDirectManager extends Runner with Logging {
  WifiDirectManager() : super(Runner.intervalSlow);

  final WifiDirect _manager = WifiDirect();
  final ClientManager _client = ClientManager();

  /// 是否开启了Wi-Fi
  bool _isEnabledWifiDirect = false;

  /// 执行的步骤
  StepFlag _step = StepFlag.none;
  void _setStep(StepFlag step) {
    _step = step;
    // var nc = ln.NotificationCenter();
    // nc.postNotification(WifiDirectNames.kStatusChanged, this, {
    //   'step': step,
    // });
  }

  /// 设备的连接信息
  WifiP2pConnection? get connection => _connection;
  WifiP2pConnection? _connection;

  /// 自己的设备信息
  WifiP2pDevice? get selfDevice => _selfDevice;
  WifiP2pDevice? _selfDevice;

  /// 搜索到的设备信息
  final Map<String, WifiP2pDevice?> _discoverDevices = {};

  /// 检测设备信息
  Future<bool> _checkDevice() async {
    logInfo('1. 检测Wi-Fi是否打开');
    if (!_isEnabledWifiDirect) {
      _setStep(StepFlag.disableWifi);
      return false;
    }
    _setStep(StepFlag.disableWifi);

    logInfo('2. 检测GPS是否打开');
    if (!await _manager.isGPSEnabled()) {
      _setStep(StepFlag.disableGPS);
      return false;
    }
    _setStep(StepFlag.enableGPS);

    logInfo('3. 检测位置权限和附近的设备权限');
    if (!await _requestPermissions()) {
      _setStep(StepFlag.disablePermission);
      return false;
    }
    _setStep(StepFlag.enablePermission);
    return true;
  }

  /// 初始化信息
  Future<bool> initialize() async {
    if (!await _checkDevice()) {
      return false;
    }

    logInfo('4. 初始化Wi-Fi管理器');
    if (!await _manager.initialize()) {
      return false;
    }
    _setStep(StepFlag.initialize);

    logInfo('5. 准备好了');
    return _discoverPeers();
  }

  /// 请求连接权限
  Future<bool> _requestPermissions() async {
    int sdk = await _manager.getPlatformSDKVersion();
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
  Future<bool> _discoverPeers() async {
    if (!await _manager.discoverPeers()) {
      return false;
    }
    logInfo('6. 开始搜索附近的设备');
    _setStep(StepFlag.discover);
    return true;
  }

  Future<void> _onConnectionSuccess(WifiP2pConnection connection) async {
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
    if (_client.isConnected) {
      logInfo('群组已建立$text，已连接无需重复连接');
      return;
    }
    String host = connection.groupOwnerAddress.substring(1);
    int port = 2121;

    SocketFlag flag = isGroupOwner ? SocketFlag.server : SocketFlag.client;
    // 启动客户端
    bool result = await _client.connectSocket(host, port, flag: flag);
    logInfo('群组已建立$text，连接Socket${result ? '成功' : '失败'}');
  }

  Future<bool> sendMessage(SocketAddress remote, IMessage message) async {
    bool? isConnected = _isConnected(remote);
    if (isConnected == null) {
      return false; // 设备不可用
    }
    // 先添加到消息队列
    _client.addData(message);
    if (isConnected) {
      logDebug('8. 已连接到设备，准备发送消息');
      _setStep(StepFlag.connected);
      return true; // 已连接，直接发送
    }
    // 未连接，先连接
    if (!await _manager.connect(remote.remoteAddress)) {
      logError('7. 连接设备失败');
      return false;
    }
    logDebug('7. 开始连接设备：remote=${remote.remoteAddress}');
    _setStep(StepFlag.connecting);
    return true;
  }

  /// 指定的ID判断设备是否连接
  bool? _isConnected(SocketAddress remote) {
    WifiP2pDevice? device = _discoverDevices[remote.remoteAddress];
    if (device == null) {
      return false;
    }
    switch (device.status) {
      case DeviceStatus.connected:
        return true;
      case DeviceStatus.invited:
        return null;
      case DeviceStatus.failed:
        return null;
      case DeviceStatus.available:
        return false;
      case DeviceStatus.unavailable:
        return null;
    }
  }

  void dispose() {
    _manager.unregister();
  }

  @override
  Future<bool> process() async {
    throw UnimplementedError();
  }
}

class WifiDirectClient extends WifiDirectManager implements P2pConnectionListener {
  WifiDirectClient() {
    // 注册监听
    _manager
      ..register()
      ..setP2pConnectionListener(this)
      ..receiveConnectionStream().listen((value) {});
    _client.start();
  }

  @override
  void onP2pState(bool enabled) async {
    logDebug('设备的 Wi-Fi Direct 启用或禁用状态：enabled=$enabled');
    bool oldEnabled = _isEnabledWifiDirect;
    _isEnabledWifiDirect = enabled;
    if (oldEnabled != enabled) {
      await initialize();
    }
  }

  @override
  void onPeersAvailable(List<WifiP2pDevice> peers) {
    logDebug('获取更新的对等点列表：peers=${jsonEncode(peers)}');
    for (var peer in peers) {
      String deviceAddress = peer.deviceAddress;
      _discoverDevices[deviceAddress] = peer;
    }
    var nc = ln.NotificationCenter();
    nc.postNotification(WifiDirectNames.kDevicesChanged, this, {
      'peers': peers,
    });
  }

  @override
  void onConnectionInfoAvailable(WifiP2pConnection connection) {
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
      return;
    }
    if (!connection.groupFormed) {
      logInfo('群组未建立');
      return;
    }
    _onConnectionSuccess(connection);
  }

  @override
  void onSelfP2pChanged(WifiP2pDevice device) {
    logDebug('设备的 Wi-Fi 状态变化：device=${device.toJson()}');
    _selfDevice = device;
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
