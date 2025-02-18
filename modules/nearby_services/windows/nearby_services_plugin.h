#ifndef FLUTTER_PLUGIN_NEARBY_SERVICES_PLUGIN_H_
#define FLUTTER_PLUGIN_NEARBY_SERVICES_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace nearby_services {

class NearbyServicesPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  NearbyServicesPlugin();

  virtual ~NearbyServicesPlugin();

  // Disallow copy and assign.
  NearbyServicesPlugin(const NearbyServicesPlugin&) = delete;
  NearbyServicesPlugin& operator=(const NearbyServicesPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace nearby_services

#endif  // FLUTTER_PLUGIN_NEARBY_SERVICES_PLUGIN_H_
