import 'package:flutter_test/flutter_test.dart';
import 'package:nearby_services/nearby_services.dart';
import 'package:nearby_services/nearby_services_platform_interface.dart';
import 'package:nearby_services/nearby_services_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockNearbyServicesPlatform
    with MockPlatformInterfaceMixin
    implements NearbyServicesPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
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
