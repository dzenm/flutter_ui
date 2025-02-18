import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'nearby_services_method_channel.dart';

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
}
