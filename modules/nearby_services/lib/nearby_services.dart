
import 'nearby_services_platform_interface.dart';

class NearbyServices {
  Future<String?> getPlatformVersion() {
    return NearbyServicesPlatform.instance.getPlatformVersion();
  }
}
