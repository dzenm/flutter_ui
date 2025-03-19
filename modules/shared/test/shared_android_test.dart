import 'package:flutter_test/flutter_test.dart';
import 'package:shared_android/shared_android.dart';
import 'package:shared_android/shared_android_platform_interface.dart';
import 'package:shared_android/shared_android_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockSharedAndroidPlatform
    with MockPlatformInterfaceMixin
    implements SharedAndroidPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final SharedAndroidPlatform initialPlatform = SharedAndroidPlatform.instance;

  test('$MethodChannelSharedAndroid is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelSharedAndroid>());
  });

  test('getPlatformVersion', () async {
    SharedAndroid sharedAndroidPlugin = SharedAndroid();
    MockSharedAndroidPlatform fakePlatform = MockSharedAndroidPlatform();
    SharedAndroidPlatform.instance = fakePlatform;

    expect(await sharedAndroidPlugin.getPlatformVersion(), '42');
  });
}
