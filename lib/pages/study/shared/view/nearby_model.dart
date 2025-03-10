import 'package:flutter/material.dart';

import 'nearby_service_page.dart';

///
/// Created by a0010 on 2025/3/10 11:04
///
class NearbyModel extends ChangeNotifier {

  AppState get state => _state;
  AppState _state = AppState.idle;

}