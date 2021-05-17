import 'package:flutter_ui/http/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences工具类
class SpUtil {
  SpUtil._internal();

  static final SpUtil _instance = SpUtil._internal();

  static SpUtil get instance => _instance;

  static SharedPreferences? _prefs;

  static const String TAG = 'SpUtil';

  static const String _USER_INFO = 'user_info';

  void init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String getUser() {
    return _prefs?.getString(_USER_INFO) ?? '';
  }

  static void setUser(String user) {
    Log.d('setUser=$user', tag: TAG);
    _prefs?.setString(_USER_INFO, user);
  }
}
