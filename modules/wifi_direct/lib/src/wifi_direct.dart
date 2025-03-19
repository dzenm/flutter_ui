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

  Future<bool> discoverPeers() async {
    return WifiDirectPlatform.instance.discoverPeers();
  }

  Future<bool> stopPeerDiscovery() async {
    return WifiDirectPlatform.instance.stopPeerDiscovery();
  }

  Future<List<WifiP2pDevice>> requestPeers() async {
    return WifiDirectPlatform.instance.requestPeers();
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

  void setP2pConnectionListener(P2pConnectionListener listener) => //
      WifiDirectPlatform.instance.setP2pConnectionListener(listener);

  Stream<String?> receiveConnectionStream() {
    return WifiDirectPlatform.instance.receiveConnectionStream();
  }
}
