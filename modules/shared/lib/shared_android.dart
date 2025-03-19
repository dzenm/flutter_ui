
import 'shared_android_platform_interface.dart';

class SharedAndroid {
  Future<String?> getPlatformVersion() {
    return SharedAndroidPlatform.instance.getPlatformVersion();
  }
}
