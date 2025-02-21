import 'nearby_services_platform_interface.dart';

class NearbyServices {
  Future<String?> getPlatformVersion() {
    return NearbyServicesPlatform.instance.getPlatformVersion();
  }

  Future<bool> initialize() async {
    return NearbyServicesPlatform.instance.initialize();
  }

  Future<bool> register() async {
    return NearbyServicesPlatform.instance.register();
  }

  Future<bool> unregister() async {
    return NearbyServicesPlatform.instance.unregister();
  }

  Future<bool> discover() async {
    return NearbyServicesPlatform.instance.discover();
  }

  Future<bool> stopDiscovery() async {
    return NearbyServicesPlatform.instance.stopDiscovery();
  }

  Future<bool> connect(String address) async {
    return NearbyServicesPlatform.instance.connect(address);
  }

  Future<bool> disconnect() async {
    return NearbyServicesPlatform.instance.disconnect();
  }

  Future<bool> createGroup() async {
    return NearbyServicesPlatform.instance.createGroup();
  }

  Future<bool> removeGroup() async {
    return NearbyServicesPlatform.instance.removeGroup();
  }

  Future<bool> isGPSEnabled() async {
    return NearbyServicesPlatform.instance.isGPSEnabled();
  }

  Future<bool> openLocationSettingsPage() async {
    return NearbyServicesPlatform.instance.openLocationSettingsPage();
  }

  Future<bool> isWifiEnabled() async {
    return NearbyServicesPlatform.instance.isWifiEnabled();
  }

  Future<bool> openWifiSettingsPage() async {
    return NearbyServicesPlatform.instance.openWifiSettingsPage();
  }
}
