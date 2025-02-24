import 'package:flutter_test/flutter_test.dart';
import 'package:nearby_services/src/entities/p2p_entity.dart';
import '../lib/nearby_services.dart';
import 'package:nearby_services/src/platforms/nearby_services_platform_interface.dart';
import 'package:nearby_services/src/platforms/nearby_services_android_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNearbyServicesPlatform
    with MockPlatformInterfaceMixin
    implements NearbyServicesPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<bool> connect(String address) => Future.value(true);

  @override
  Future<bool> createGroup() => Future.value(true);

  @override
  Future<bool> disconnect() => Future.value(true);

  @override
  Future<bool> discover() => Future.value(true);

  @override
  Future<String?> getPlatformModel() => Future.value('Google');

  @override
  Future<bool> initialize() => Future.value(true);

  @override
  Future<bool> isGPSEnabled() => Future.value(true);

  @override
  Future<bool> isWifiEnabled() => Future.value(true);

  @override
  Future<bool> openLocationSettingsPage() => Future.value(true);

  @override
  Future<bool> openWifiSettingsPage() => Future.value(true);

  @override
  Future<bool> register() => Future.value(true);

  @override
  Future<bool> removeGroup() => Future.value(true);

  @override
  Future<bool> stopDiscovery() => Future.value(true);

  @override
  Future<bool> unregister() => Future.value(true);

  @override
  Stream<List<PeerInfo>> discoverPeersStream() {
    throw UnimplementedError();
  }

  @override
  Stream<WifiP2PInfo> wifiP2PStream() {
    throw UnimplementedError();
  }
}

void main() {
  final NearbyServicesPlatform initialPlatform = NearbyServicesPlatform.instance;

  test('$MethodChannelNearbyServices is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelNearbyServices>());
  });

  test('getPlatformVersion', () async {
    NearbyServices nearbyServicesPlugin = NearbyServices();
    MockNearbyServicesPlatform fakePlatform = MockNearbyServicesPlatform();
    NearbyServicesPlatform.instance = fakePlatform;

    expect(await nearbyServicesPlugin.getPlatformVersion(), '42');
  });
}
