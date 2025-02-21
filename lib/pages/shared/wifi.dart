import 'package:fbl/fbl.dart';

import 'transfer/src/connection.dart';

///
/// Created by a0010 on 2025/2/5 15:07
/// Wifi管理工具
class WifiManager with Logging implements WifiConnection {
  static final WifiManager _instance = WifiManager._();
  WifiManager._();
  factory WifiManager() => _instance;

}
