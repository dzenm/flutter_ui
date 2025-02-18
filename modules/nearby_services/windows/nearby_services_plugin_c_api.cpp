#include "include/nearby_services/nearby_services_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "nearby_services_plugin.h"

void NearbyServicesPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  nearby_services::NearbyServicesPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
