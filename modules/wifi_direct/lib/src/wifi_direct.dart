import 'data.dart';
import 'wifi_direct_platform_interface.dart';

export 'data.dart';

class WifiDirect {
  Future<String?> getPlatformVersion() async {
    return await WifiDirectPlatform.instance.getPlatformVersion();
  }

  Future<int> getPlatformSDKVersion() async {
    return await WifiDirectPlatform.instance.getPlatformSDKVersion();
  }

  Future<bool> initialize() async {
    return await WifiDirectPlatform.instance.initialize();
  }

  Future<bool> register() async {
    return await WifiDirectPlatform.instance.register();
  }

  Future<bool> unregister() async {
    return await WifiDirectPlatform.instance.unregister();
  }

  Future<bool> discoverPeers() async {
    return await WifiDirectPlatform.instance.discoverPeers();
  }

  Future<bool> stopPeerDiscovery() async {
    return await WifiDirectPlatform.instance.stopPeerDiscovery();
  }

  Future<List<WifiP2pDevice>> requestPeers() async {
    return await WifiDirectPlatform.instance.requestPeers();
  }

  Future<bool> connect(String address) async {
    return await WifiDirectPlatform.instance.connect(address);
  }

  Future<bool> disconnect() async {
    return await WifiDirectPlatform.instance.disconnect();
  }

  Future<WifiP2pGroup?> requestGroup() async {
    return await WifiDirectPlatform.instance.requestGroup();
  }

  Future<bool> createGroup() async {
    return await WifiDirectPlatform.instance.createGroup();
  }

  Future<bool> removeGroup() async {
    return await WifiDirectPlatform.instance.removeGroup();
  }

  Future<bool> isGPSEnabled() async {
    return await WifiDirectPlatform.instance.isGPSEnabled();
  }

  Future<bool> openLocationSettingsPage() async {
    return await WifiDirectPlatform.instance.openLocationSettingsPage();
  }

  Future<bool> isWifiEnabled() async {
    return await WifiDirectPlatform.instance.isWifiEnabled();
  }

  Future<bool> openWifiSettingsPage() async {
    return await WifiDirectPlatform.instance.openWifiSettingsPage();
  }

  void setP2pConnectionListener(P2pConnectionListener listener) => //
      WifiDirectPlatform.instance.setP2pConnectionListener(listener);

  Stream<bool> receiveConnectionStream() {
    return WifiDirectPlatform.instance.receiveConnectionStream();
  }
}
