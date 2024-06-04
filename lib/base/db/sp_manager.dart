import 'package:shared_preferences/shared_preferences.dart';

///
/// Created by a0010 on 2022/3/22 09:38
/// SharedPreferences工具类
class SPManager {
  static final SPManager _instance = SPManager._internal();
  static SPManager get instance => _instance;
  factory SPManager() => _instance;
  SPManager._internal();

  SharedPreferences? _prefs;

  /// 日志打印，如果不设置，将不打印日志，如果要设置在使用数据库之前调用 [init]
  Function? _logPrint;

  Future<bool> init({Function? logPrint}) async {
    _prefs = await SharedPreferences.getInstance();
    _logPrint = logPrint;
    return _prefs != null;
  }

  ///============================== SP对外提供增加/获取的方法 @see [SPValue] ================================

  /// 登录状态信息
  static bool getUserLoginState() {
    return getBool(SPValue.userLoginState.value);
  }

  /// 保存登录状态信息
  static void setUserLoginState(bool? isLogin) {
    setBool(SPValue.userLoginState.value, isLogin);
  }

  /// 获取用户信息
  static String getUser() {
    return getString(SPValue.user.value);
  }

  /// 保存用户信息
  static void setUser(String? user) {
    setString(SPValue.user.value, user);
  }

  /// 获取登录用户ID
  static String getUserId() {
    return getString(SPValue.userId.value);
  }

  /// 保存登录用户ID
  static void setUserId(String? userId) {
    setString(SPValue.userId.value, userId);
  }

  /// 获取用户名
  static String getUsername() {
    return getString(SPValue.userName.value);
  }

  /// 保存用户名
  static void setUsername(String? username) {
    setString(SPValue.userName.value, username);
  }

  /// 获取用户信息
  static String getUserInfo() {
    return getString(SPValue.userInfo.value);
  }

  /// 保存用户信息
  static void setUserInfo(String? user) {
    setString(SPValue.userInfo.value, user);
  }

  /// 获取登录用户token
  static String getToken() {
    return getString(SPValue.userToken.value);
  }

  /// 保存登录用户token
  static void setToken(String? token) {
    setString(SPValue.userToken.value, token);
  }

  /// 获取登录用户cookie
  static String getCookie() {
    return getString(SPValue.userCookie.value);
  }

  /// 保存登录用户cookie
  static void setCookie(String? cookie) {
    setString(SPValue.userCookie.value, cookie);
  }

  /// 重置登录用户信息
  static void clearUser() {
    remove(SPValue.userInfo.value);
    remove(SPValue.userLoginState.value);
    remove(SPValue.user.value);
    remove(SPValue.userId.value);
    remove(SPValue.userToken.value);
    remove(SPValue.userCookie.value);
  }

  /// 获取APP设置
  static String getSettings() {
    String settings = getString(SPValue.settings.value);
    return settings;
  }

  /// 保存APP设置
  static void setSettings(String? settings) {
    setString(SPValue.settings.value, settings);
  }

  ///============================== SP基本数据类型的操作 ================================

  static String getString(String key) {
    String value = _instance._prefs?.getString(key) ?? '';
    _instance.log('获取string值：key=$key, value=$value');
    return value;
  }

  static void setString(String key, String? value) {
    _instance._prefs?.setString(key, value ?? '').then((res) {
      _instance.log('设置string值：key=$key, value=$value');
    });
  }

  static int getInt(String key) {
    int value = _instance._prefs?.getInt(key) ?? 0;
    _instance.log('获取int值：key=$key, value=$value');
    return value;
  }

  static void setInt(String key, int? value) {
    _instance._prefs?.setInt(key, value ?? 0).then((res) {
      _instance.log('设置int值：key=$key, value=$value');
    });
  }

  static bool getBool(String key) {
    bool value = _instance._prefs?.getBool(key) ?? false;
    _instance.log('获取bool值  ：key=$key, value=$value');
    return value;
  }

  static void setBool(String key, bool? value) {
    _instance._prefs?.setBool(key, value ?? false).then((res) {
      _instance.log('设置bool值  ：key=$key, value=$value');
    });
  }

  static void remove(String key) {
    _instance.log('remove $key=$key');
    _instance._prefs?.remove(key);
  }

  void log(String text) => _logPrint == null ? null : _logPrint!(text, tag: 'SPManager');
}

enum SPValue {
  /// 用户登录相关的信息
  userLoginState('u_login_state'), // 登录状态的信息
  user('u_user'), // 登录的用户
  userId('u_id'), // 用户ID
  userName('u_name'), // 用户名
  userInfo('u_info'), // 用户信息
  userToken('u_token'), // 登录的token信息
  userCookie('u_cookie'), // 登录的cookie信息
  /// APP设置相关的信息
  settings('settings'); // APP相关的设置

  final String value;

  const SPValue(this.value);
}
