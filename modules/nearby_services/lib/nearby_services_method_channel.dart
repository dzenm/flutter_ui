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

  @override
  Future<bool> initialize() async {
    final result = await methodChannel.invokeMethod<bool>('initialize');
    return result ?? false;
  }

  @override
  Future<bool> register() async {
    final result = await methodChannel.invokeMethod<bool>('register');
    return result ?? false;
  }

  @override
  Future<bool> unregister() async {
    final result = await methodChannel.invokeMethod<bool>('unregister');
    return result ?? false;
  }

  @override
  Future<bool> discover() async {
    final result = await methodChannel.invokeMethod<bool>('discover');
    return result ?? false;
  }

  @override
  Future<bool> stopDiscovery() async {
    final result = await methodChannel.invokeMethod<bool>('stopDiscovery');
    return result ?? false;
  }

  @override
  Future<bool> connect(String address) async {
    final args = {
      "address": address,
    };
    final result = await methodChannel.invokeMethod<bool>("connect", args);
    return result ?? false;
  }

  @override
  Future<bool> disconnect() async {
    final result = await methodChannel.invokeMethod<bool>('disconnect');
    return result ?? false;
  }

  @override
  Future<bool> createGroup() async {
    final result = await methodChannel.invokeMethod<bool>('createGroup');
    return result ?? false;
  }

  @override
  Future<bool> removeGroup() async {
    final result = await methodChannel.invokeMethod<bool>('removeGroup');
    return result ?? false;
  }

  @override
  Future<bool> isGPSEnabled() async {
    final result = await methodChannel.invokeMethod<bool>('isGPSEnabled');
    return result ?? false;
  }

  @override
  Future<bool> openLocationSettingsPage() async {
    final result = await methodChannel.invokeMethod<bool>('openLocationSettingsPage');
    return result ?? false;
  }

  @override
  Future<bool> isWifiEnabled() async {
    final result = await methodChannel.invokeMethod<bool>('isWifiEnabled');
    return result ?? false;
  }

  @override
  Future<bool> openWifiSettingsPage() async {
    final result = await methodChannel.invokeMethod<bool>('openWifiSettingsPage');
    return result ?? false;
  }
}
