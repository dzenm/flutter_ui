import 'package:shared_preferences/shared_preferences.dart';

///
/// Created by a0010 on 2022/3/22 09:38
/// SharedPreferences工具类
class SPManager with _SharedPreferencesMixin {
  SPManager._internal();
  static final SPManager _instance = SPManager._internal();
  factory SPManager() => _instance;

  /// [prefix] 设置文件的前缀命名，默认为`flutter`
  /// [logPrint] 如果不设置，将不打印日志
  Future<bool> init({String? prefix, Function? logPrint}) async {
    if (prefix != null) {
      SharedPreferences.setPrefix(prefix);
    }
    _prefs = await SharedPreferences.getInstance();
    _logPrint = logPrint;
    return _prefs != null;
  }

  ///============================== SP对外提供增加/获取的方法 @see [SPValue] ================================

  /// 登录状态信息
  static bool getUserLoginState() {
    return _instance.getBool(SPValue.userLoginState.value);
  }

  /// 保存登录状态信息
  static void setUserLoginState(bool? isLogin) {
    _instance.setBool(SPValue.userLoginState.value, isLogin);
  }

  /// 获取用户信息
  static String getUser() {
    return _instance.getString(SPValue.user.value);
  }

  /// 保存用户信息
  static void setUser(String? user) {
    _instance.setString(SPValue.user.value, user);
  }

  /// 获取登录用户ID
  static String getUserId() {
    return _instance.getString(SPValue.userId.value);
  }

  /// 保存登录用户ID
  static void setUserId(String? userId) {
    _instance.setString(SPValue.userId.value, userId);
  }

  /// 获取用户名
  static String getUsername() {
    return _instance.getString(SPValue.userName.value);
  }

  /// 保存用户名
  static void setUsername(String? username) {
    _instance.setString(SPValue.userName.value, username);
  }

  /// 获取用户信息
  static String getUserInfo() {
    return _instance.getString(SPValue.userInfo.value);
  }

  /// 保存用户信息
  static void setUserInfo(String? user) {
    _instance.setString(SPValue.userInfo.value, user);
  }

  /// 获取登录用户token
  static String getToken() {
    return _instance.getString(SPValue.userToken.value);
  }

  /// 保存登录用户token
  static void setToken(String? token) {
    _instance.setString(SPValue.userToken.value, token);
  }

  /// 重置登录用户信息
  static void clearUser() {
    for (var item in SPValue.values) {
      _instance.remove(item.value);
    }
  }

  /// 获取APP设置
  static String getSettings() {
    String settings = _instance.getString(SPValue.settings.value);
    return settings;
  }

  /// 保存APP设置
  static void setSettings(String? settings) {
    _instance.setString(SPValue.settings.value, settings);
  }

///============================== SP基本数据类型的操作 ================================
}

/// SharedPreference 的基本API
abstract mixin class _SharedPreferencesMixin {
  SharedPreferences? _prefs;
  Function? _logPrint;

  String getString(String key) {
    String value = _prefs?.getString(key) ?? '';
    log('获取`String`值：key=$key, value=$value');
    return value;
  }

  void setString(String key, String? value) {
    _prefs?.setString(key, value ?? '').then((result) {
      log('设置`String`值：key=$key, value=$value, result=$result');
    });
  }

  int getInt(String key) {
    int value = _prefs?.getInt(key) ?? 0;
    log('获取`Int`值   ：key=$key, value=$value');
    return value;
  }

  void setInt(String key, int? value) {
    _prefs?.setInt(key, value ?? 0).then((result) {
      log('设置`Int`值   ：key=$key, value=$value, result=$result');
    });
  }

  double getDouble(String key) {
    double value = _prefs?.getDouble(key) ?? 0.0;
    log('获取`Double`值：key=$key, value=$value');
    return value;
  }

  void setDouble(String key, double? value) {
    _prefs?.setDouble(key, value ?? 0.0).then((result) {
      log('设置`Double`值：key=$key, value=$value, result=$result');
    });
  }

  bool getBool(String key) {
    bool value = _prefs?.getBool(key) ?? false;
    log('获取`Bool`值  ：key=$key, value=$value');
    return value;
  }

  void setBool(String key, bool? value) {
    _prefs?.setBool(key, value ?? false).then((result) {
      log('设置`Bool`值  ：key=$key, value=$value, result=$result');
    });
  }

  List<String> getStringList(String key) {
    List<String> value = _prefs?.getStringList(key) ?? [];
    log('获取`List`值  ：key=$key, value=$value');
    return value;
  }

  void setStringList(String key, List<String>? value) {
    _prefs?.setStringList(key, value ?? []).then((result) {
      log('设置`List`值  ：key=$key, value=$value, result=$result');
    });
  }

  void remove(String key) {
    _prefs?.remove(key).then((result) {
      log('移除值 $key=$key, result=$result');
    });
  }

  void reload() {
    _prefs?.reload().then((result) {
      log('重新加载');
    });
  }

  void log(String text) => _logPrint == null ? null : _logPrint!(text, tag: 'SPManager');
}

enum SPValue {
  /// 用户登录相关的信息
  userLoginState('u_login_state'), // 登录状态的信息
  user('u_user'), // 登录的用户
  userId('u_id'), // 用户ID
  userName('u_name'), // 用户名
  userToken('u_token'), // 登录的token信息
  userInfo('u_info'), // 用户信息
  /// APP设置相关的信息
  settings('u_settings'); // APP相关的设置

  final String value;

  const SPValue(this.value);
}
