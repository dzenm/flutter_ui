import 'data.dart';
import 'wifi_direct_platform_interface.dart';

export 'data.dart';

class WifiDirect {
  Future<String?> getPlatformVersion() {
    return WifiDirectPlatform.instance.getPlatformVersion();
  }

  Future<bool> initialize() async {
    return WifiDirectPlatform.instance.initialize();
  }

  Future<bool> register() async {
    return WifiDirectPlatform.instance.register();
  }

  Future<bool> unregister() async {
    return WifiDirectPlatform.instance.unregister();
  }

  Future<bool> discover() async {
    return WifiDirectPlatform.instance.discover();
  }

  Future<bool> stopDiscovery() async {
    return WifiDirectPlatform.instance.stopDiscovery();
  }

  Future<bool> connect(String address) async {
    return WifiDirectPlatform.instance.connect(address);
  }

  Future<bool> disconnect() async {
    return WifiDirectPlatform.instance.disconnect();
  }

  Future<WifiP2pGroup?> requestGroup() async {
    return WifiDirectPlatform.instance.requestGroup();
  }

  Future<bool> createGroup() async {
    return WifiDirectPlatform.instance.createGroup();
  }

  Future<bool> removeGroup() async {
    return WifiDirectPlatform.instance.removeGroup();
  }

  Future<bool> isGPSEnabled() async {
    return WifiDirectPlatform.instance.isGPSEnabled();
  }

  Future<bool> openLocationSettingsPage() async {
    return WifiDirectPlatform.instance.openLocationSettingsPage();
  }

  Future<bool> isWifiEnabled() async {
    return WifiDirectPlatform.instance.isWifiEnabled();
  }

  Future<bool> openWifiSettingsPage() async {
    return WifiDirectPlatform.instance.openWifiSettingsPage();
  }

  Stream<List<WifiP2pDevice>> getDiscoverPeersStream() {
    return WifiDirectPlatform.instance.getDiscoverPeersStream();
  }

  Stream<WifiP2pInfo> getWifiStream() {
    return WifiDirectPlatform.instance.getWifiStream();
  }

  void cancel() {
    WifiDirectPlatform.instance.cancel();
  }
}
