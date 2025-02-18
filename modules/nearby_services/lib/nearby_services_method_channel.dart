import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'nearby_services_platform_interface.dart';

/// An implementation of [NearbyServicesPlatform] that uses method channels.
class MethodChannelNearbyServices extends NearbyServicesPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('nearby_services');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
