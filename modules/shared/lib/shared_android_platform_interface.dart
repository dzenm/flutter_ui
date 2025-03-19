import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'shared_android_method_channel.dart';

abstract class SharedAndroidPlatform extends PlatformInterface {
  /// Constructs a SharedAndroidPlatform.
  SharedAndroidPlatform() : super(token: _token);

  static final Object _token = Object();

  static SharedAndroidPlatform _instance = MethodChannelSharedAndroid();

  /// The default instance of [SharedAndroidPlatform] to use.
  ///
  /// Defaults to [MethodChannelSharedAndroid].
  static SharedAndroidPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SharedAndroidPlatform] when
  /// they register themselves.
  static set instance(SharedAndroidPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
