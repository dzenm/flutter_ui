import 'package:nearby_services/src/entities/p2p_entity.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'nearby_services_android_channel.dart';

abstract class NearbyServicesPlatform extends PlatformInterface {
  /// Constructs a NearbyServicesPlatform.
  NearbyServicesPlatform() : super(token: _token);

  static final Object _token = Object();

  static NearbyServicesPlatform _instance = MethodChannelNearbyServices();

  /// The default instance of [NearbyServicesPlatform] to use.
  ///
  /// Defaults to [MethodChannelNearbyServices].
  static NearbyServicesPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NearbyServicesPlatform] when
  /// they register themselves.
  static set instance(NearbyServicesPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> getPlatformModel() {
    throw UnimplementedError('getPlatformModel() has not been implemented.');
  }

  Future<bool> initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  Future<bool> register() {
    throw UnimplementedError('register() has not been implemented.');
  }

  Future<bool> unregister() {
    throw UnimplementedError('unregister() has not been implemented.');
  }

  Future<bool> discover() {
    throw UnimplementedError('discover() has not been implemented.');
  }

  Future<bool> stopDiscovery() {
    throw UnimplementedError('stopDiscovery() has not been implemented.');
  }

  Future<bool> connect(String address) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  Future<bool> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  Future<bool> createGroup() {
    throw UnimplementedError('createGroup() has not been implemented.');
  }

  Future<bool> removeGroup() {
    throw UnimplementedError('removeGroup() has not been implemented.');
  }

  Future<bool> isGPSEnabled() {
    throw UnimplementedError('isGPSEnabled() has not been implemented.');
  }

  Future<bool> openLocationSettingsPage() {
    throw UnimplementedError(
        'openLocationSettingsPage() has not been implemented.');
  }

  Future<bool> isWifiEnabled() {
    throw UnimplementedError('isWifiEnabled() has not been implemented.');
  }

  Future<bool> openWifiSettingsPage() {
    throw UnimplementedError('openWifiSettingsPage() has not been implemented.');
  }

  Stream<List<PeerInfo>> discoverPeersStream() {
    throw UnimplementedError(
        'discoverPeersStream() has not been implemented.');
  }

  Stream<WifiP2PInfo> wifiP2PStream() {
    throw UnimplementedError(
        'wifiP2PStream() has not been implemented.');
  }
}
