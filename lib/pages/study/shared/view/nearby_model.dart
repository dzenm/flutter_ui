import 'package:flutter/material.dart';

import 'nearby_service_page.dart';

///
/// Created by a0010 on 2025/3/10 11:04
///
class NearbyModel extends ChangeNotifier {

  AppState get state => _state;
  AppState _state = AppState.idle;

  get isIOSBrowser => null;

  get discover => null;

  get stopDiscovery => null;

  get startListeningPeers => null;


  void requestPermissions() {
  }

  checkWifiService() {}

  void openServicesSettings() {
  }

  sendTextRequest(String message) {}

  sendFilesRequest(List<String> list) {}

  void stopListeningPeers() {
  }

  void setIsBrowser({required bool value}) {}

  void updateState(AppState selectClientType) {}

  getSavedIOSDeviceName() {}

  void initialize(String text) {}
}