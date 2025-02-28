import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_direct/wifi_direct.dart';

import '../connection/wifi_direct.dart';

///
/// Created by a0010 on 2025/2/26 11:28
///
class Android2Android {
  WifiDirectConnectionClient connection = WifiDirectConnectionClient();

  Future<bool> initialize({bool isGroup = true}) async {
    await _checkPermission();
    return await connection.initialize(isGroup: isGroup);
  }

  void connect(String deviceAddress) {
    connection.connect(deviceAddress);
  }

  void dispose() {
    connection.dispose();
  }

  Stream<List<WifiP2pDevice>> get discoverPeersStream => connection.discoverPeersStream;
  Stream<WifiP2pInfo> get wifiStream => connection.wifiStream;

  /// 执行前先检查
  void _check(void Function() callback) async {
    if (!await _checkPermission()) return;
    callback();
  }

  /// 检查权限
  Future<bool> _checkPermission() async {
    // 判断位置服务有没有打开
    if (await connection.client.isGPSEnabled()) {
      // 判断Wi-Fi服务有没有打开
      if (await connection.client.isWifiEnabled()) {
        // 请求权限
        return await _requestPermissions();
      } else {
        // 进入Wi-Fi设置
        await connection.client.openWifiSettingsPage();
      }
    } else {
      // 进入位置服务设置
      await connection.client.openLocationSettingsPage();
    }
    return false;
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

}