import 'package:fbl/fbl.dart';
import 'package:universal_ble/universal_ble.dart';

import '../service/connection.dart';

///
/// Created by a0010 on 2025/2/26 11:25
///
class BleConnectionClient with Logging implements BleConnection {
  static final BleConnectionClient _instance = BleConnectionClient._();

  BleConnectionClient._();

  factory BleConnectionClient() => _instance;
  final Map<String, BleEntity> _devices = {};

  bool _isRunning = false;

  /// Get already connected devices
  /// You can set `withServices` to narrow down the results
  /// On `Apple`, `withServices` is required to get connected devices, else [1800] service will be used as default filter.
  Future<List<BleDevice>> get connectedDevices async => //
      await UniversalBle.getSystemDevices(withServices: []);

  /// 返回值：null=蓝牙不可用；false=蓝牙未打开；true=蓝牙已打开且可用
  Future<bool?> start() async {
    if (_isRunning) {
      await stop();
    }
    _isRunning = true;
    // 1.扫描前，确保蓝牙可用，如果不可用，将返回null
    AvailabilityState state = await UniversalBle.getBluetoothAvailabilityState();
    // Start scan only if Bluetooth is powered on
    if (state == AvailabilityState.poweredOff) {
      logInfo('蓝牙未开启，开启蓝牙状态变化监听');
      // Or listen to bluetooth availability changes
      UniversalBle.onAvailabilityChange = (state) {
        if (state == AvailabilityState.poweredOn) {
          _startScan();
        }
      };
      return false;
    } else if (state == AvailabilityState.poweredOn) {
      logInfo('蓝牙已开启，开始扫描设备');
      _startScan();
      return true;
    }
    logInfo('蓝牙不可用');
    return null;
  }

  Future<void> _startScan() async {
    logInfo('开始扫描蓝牙');
    // 开始扫描蓝牙
    // Set a scan result handler
    UniversalBle.onScanResult = (BleDevice scanResult) {
      // e.g. Use BleDevice ID to connect
      String deviceId = scanResult.deviceId;
      BleEntity? ble = _devices[deviceId];
      if (ble == null) {
        if (deviceId.isNotEmpty && scanResult.name != null) {
          logInfo('扫描到新的蓝牙设备：$scanResult');
          ble = BleEntity(deviceId: deviceId, name: scanResult.name ?? '');
          _devices[deviceId] = ble;
        }
      }
    };
    // Perform a scan
    await UniversalBle.startScan(
      scanFilter: ScanFilter(),
      platformConfig: PlatformConfig(),
    );
  }

  Future<bool> sendData(BleDevice bleDevice) async {
    // Connect to a device using the `deviceId` of the BleDevice received from `UniversalBle.onScanResult`
    String deviceId = bleDevice.deviceId;
    // Get current connection state
    // Can be connected, disconnected, connecting or disconnecting
    BleConnectionState state = await bleDevice.connectionState;
    if (state == BleConnectionState.connected) {
      // Discover services of a specific device
      await UniversalBle.discoverServices(deviceId);
    } else if (state == BleConnectionState.disconnected) {
      // Get connection/disconnection updates
      UniversalBle.onConnectionChange = (String deviceId, bool isConnected, String? error) {
        logInfo('连接回调：deviceId=$deviceId, isConnected=$isConnected, error=$error');
      };
      await UniversalBle.connect(deviceId);
    }
    return true;
  }

  /// 断开连接
  Future<bool> disconnect(BleDevice bleDevice) async {
    // Get current connection state
    // Can be connected, disconnected, connecting or disconnecting
    BleConnectionState state = await bleDevice.connectionState;
    if (state == BleConnectionState.disconnected) {
      return true;
    } else if (state == BleConnectionState.disconnecting) {
      return true;
    }
    String deviceId = bleDevice.deviceId;
    // Disconnect from a device
    await UniversalBle.disconnect(deviceId);
    return true;
  }

  Future<void> stop() async {
    logInfo('关闭蓝牙扫描');
    // Stop scanning
    UniversalBle.stopScan();
    _isRunning = false;
  }

  void open() {}

  void close() {}

  @override
  bool get isConnected => true;

  @override
  bool get isTransiting => true;

  @override
  Future<bool> initialize() async {
    return true;
  }

  @override
  void dispose() {
    // TODO: implement unregister
  }

  @override
  // TODO: implement isPrepare
  bool get isPrepare => throw UnimplementedError();

  @override
  void connect(String deviceAddress) {
    // TODO: implement scan
  }
}

class BleEntity {
  String deviceId;
  String name;
  String rawName;
  int? rssi;
  bool? isPaired;
  List<String> services;
  bool? isSystemDevice;
  List<ManufacturerData> manufacturerDataList;
  bool isDiscover = false;

  /// Returns connection state of the device.
  /// All platforms will return `Connected/Disconnected` states.
  /// `Android` and `Apple` can also return `Connecting/Disconnecting` states.
  Future<BleConnectionState> get connectionState => UniversalBle.getConnectionState(deviceId);

  /// On web, it returns true if the web browser supports receiving advertisements from this device.
  /// The rest of the platforms will always return true.
  bool get receivesAdvertisements => UniversalBle.receivesAdvertisements(deviceId);

  BleEntity({
    required this.deviceId,
    required String name,
    this.rssi,
    this.isPaired,
    this.services = const [],
    this.isSystemDevice,
    this.manufacturerDataList = const [],
  })  : rawName = name,
        name = name.replaceAll(RegExp(r'[^ -~]'), '').trim();

  @override
  String toString() {
    return 'BleDevice: '
        'deviceId: $deviceId, '
        'name: $name, '
        'rssi: $rssi, '
        'isPaired: $isPaired, '
        'services: $services, '
        'isSystemDevice: $isSystemDevice, '
        'manufacturerDataList: $manufacturerDataList';
  }
}
