import 'package:pp_transfer/pp_transfer.dart';

/// 设备处理
mixin DeviceMixin {
  final Map<String, WifiP2pDevice?> _allDevices = {};

  WifiP2pDevice? get(String deviceAddress) {
    return _allDevices[deviceAddress];
  }

  Future<void> setDevice(String deviceAddress, WifiP2pDevice? device) async {
    // 1. replace with new device
    WifiP2pDevice? old = _allDevices[deviceAddress];
    _allDevices[deviceAddress] = device;
    // 2. close old device
    if (old == null || identical(old, device)) {
    } else {}
  }

  void clearAll() {
    _allDevices.clear();
  }
}
