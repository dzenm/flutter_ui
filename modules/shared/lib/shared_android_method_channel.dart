import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'shared_android_platform_interface.dart';

/// An implementation of [SharedAndroidPlatform] that uses method channels.
class MethodChannelSharedAndroid extends SharedAndroidPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('shared_android');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
