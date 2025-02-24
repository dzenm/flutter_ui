import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nearby_services/src/platforms/nearby_services_android_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelNearbyServices platform = MethodChannelNearbyServices();
  const MethodChannel channel = MethodChannel('nearby_services');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
