import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:wifi_direct/src/wifi_direct.dart';
import 'package:wifi_direct/src/wifi_direct_android.dart';
import 'package:wifi_direct/src/wifi_direct_platform_interface.dart';

class MockWifiDirectPlatform with MockPlatformInterfaceMixin implements WifiDirectPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<int> getPlatformSDKVersion() => Future.value(0);

  @override
  Future<bool> connect(String address) {
    // TODO: implement connect
    throw UnimplementedError();
  }

  @override
  Future<bool> createGroup() {
    // TODO: implement createGroup
    throw UnimplementedError();
  }

  @override
  Future<bool> disconnect() {
    // TODO: implement disconnect
    throw UnimplementedError();
  }

  @override
  Future<bool> discoverPeers() {
    // TODO: implement discoverPeers
    throw UnimplementedError();
  }

  @override
  Stream<bool> receiveConnectionStream() {
    // TODO: implement getConnectionStream
    throw UnimplementedError();
  }

  @override
  Future<String?> getPlatformModel() {
    // TODO: implement getPlatformModel
    throw UnimplementedError();
  }

  @override
  Future<bool> initialize() {
    // TODO: implement initialize
    throw UnimplementedError();
  }

  @override
  Future<bool> isGPSEnabled() {
    // TODO: implement isGPSEnabled
    throw UnimplementedError();
  }

  @override
  Future<bool> isWifiEnabled() {
    // TODO: implement isWifiEnabled
    throw UnimplementedError();
  }

  @override
  Future<bool> openLocationSettingsPage() {
    // TODO: implement openLocationSettingsPage
    throw UnimplementedError();
  }

  @override
  Future<bool> openWifiSettingsPage() {
    // TODO: implement openWifiSettingsPage
    throw UnimplementedError();
  }

  @override
  Future<bool> register() {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Future<bool> removeGroup() {
    // TODO: implement removeGroup
    throw UnimplementedError();
  }

  @override
  Future<WifiP2pGroup?> requestGroup() {
    // TODO: implement requestGroup
    throw UnimplementedError();
  }

  @override
  Future<List<WifiP2pDevice>> requestPeers() {
    // TODO: implement requestPeers
    throw UnimplementedError();
  }

  @override
  void setP2pConnectionListener(P2pConnectionListener listener) {
    // TODO: implement setP2pConnectionListener
  }

  @override
  Future<bool> stopPeerDiscovery() {
    // TODO: implement stopPeerDiscovery
    throw UnimplementedError();
  }

  @override
  Future<bool> unregister() {
    // TODO: implement unregister
    throw UnimplementedError();
  }

}

void main() {
  final WifiDirectPlatform initialPlatform = WifiDirectPlatform.instance;

  test('$WifiDirectAndroid is the default instance', () {
    expect(initialPlatform, isInstanceOf<WifiDirectAndroid>());
  });

  test('getPlatformVersion', () async {
    WifiDirect wifiDirectPlugin = WifiDirect();
    MockWifiDirectPlatform fakePlatform = MockWifiDirectPlatform();
    WifiDirectPlatform.instance = fakePlatform;

    expect(await wifiDirectPlugin.getPlatformVersion(), '42');
  });
}
