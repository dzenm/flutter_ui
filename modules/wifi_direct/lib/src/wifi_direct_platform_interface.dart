import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'data.dart';
import 'wifi_direct_android.dart';

abstract class WifiDirectPlatform extends PlatformInterface {
  /// Constructs a WifiDirectPlatform.
  WifiDirectPlatform() : super(token: _token);

  static final Object _token = Object();

  static WifiDirectPlatform _instance = WifiDirectAndroid();

  /// The default instance of [WifiDirectPlatform] to use.
  ///
  /// Defaults to [WifiDirectAndroid].
  static WifiDirectPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WifiDirectPlatform] when
  /// they register themselves.
  static set instance(WifiDirectPlatform instance) {
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

  Future<bool> discoverPeers() {
    throw UnimplementedError('discoverPeers() has not been implemented.');
  }

  Future<bool> stopPeerDiscovery() {
    throw UnimplementedError('stopPeerDiscovery() has not been implemented.');
  }

  Future<List<WifiP2pDevice>> requestPeers() {
    throw UnimplementedError('requestPeers() has not been implemented.');
  }

  Future<bool> connect(String address) {
    throw UnimplementedError('connect() has not been implemented.');
  }

  Future<bool> disconnect() {
    throw UnimplementedError('disconnect() has not been implemented.');
  }

  Future<WifiP2pGroup?> requestGroup() {
    throw UnimplementedError('requestGroup() has not been implemented.');
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

  void setP2pConnectionListener(P2pConnectionListener listener) {
    throw UnimplementedError(
        'setP2pConnectionListener() has not been implemented.');
  }

  Stream<String?> receiveConnectionStream() {
    throw UnimplementedError(
        'receiveConnectionStream() has not been implemented.');
  }
}
