import 'package:flutter_ui/base/log/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences工具类
class SpUtil {
  SpUtil._internal();

  static final SpUtil _getInstance = SpUtil._internal();

  static SpUtil get getInstance => _getInstance;

  static SharedPreferences? _prefs;

  static const String _TAG = 'SP数据';

  static const String _USER_INFO = 'u_user_info';

  static const String _IS_LOGIN = 'u_is_login';
  static const String _USER_USER = 'u_user';
  static const String _USER_USERNAME = 'u_username';
  static const String _USER_USER_ID = 'u_user_id';
  static const String _USER_TOKEN = 'u_token';

  static const String _SETTING_THEME = 's_theme';
  static const String _SETTING_LOCALE = 's_locale';

  Future init() async {
    _prefs = await SharedPreferences.getInstance();
    Log.d('初始化 SharedPreferences ${_prefs != null ? '成功' : '失败'}');
  }

  // 获取用户信息
  static String getUserInfo() {
    return getString(_USER_INFO);
  }

  // 保存用户信息
  static void setUserInfo(String? user) {
    setString(_USER_INFO, user);
  }

  // 是否登录信息
  static bool getIsLogin() {
    return getBool(_IS_LOGIN);
  }

  // 保存登录信息
  static void setIsLogin(bool? isLogin) {
    setBool(_IS_LOGIN, isLogin);
  }

  // 获取用户信息
  static String getUser() {
    return getString(_USER_USER);
  }

  // 保存用户信息
  static void setUser(String? user) {
    setString(_USER_USER, user);
  }

// 获取用户名
  static String getUsername() {
    return getString(_USER_USERNAME);
  }

  // 保存用户名
  static void setUsername(String? username) {
    setString(_USER_USERNAME, username);
  }

  // 获取登录用户ID
  static String getUserId() {
    return getString(_USER_USER_ID);
  }

  // 保存登录用户ID
  static void setUserId(String? userId) {
    setString(_USER_USER_ID, userId);
  }

  // 获取登录用户token
  static String getToken() {
    return getString(_USER_TOKEN);
  }

  // 保存登录用户token
  static void setToken(String? token) {
    setString(_USER_TOKEN, token);
  }

  // 获取主题样式
  static String getTheme() {
    String theme = getString(_SETTING_THEME);
    return theme.isEmpty ? 'blue' : theme;
  }

  // 保存主题样式
  static void setTheme(String? theme) {
    setString(_SETTING_THEME, theme);
  }

  // 获取语言设置
  static String getLocale() {
    String locale = getString(_SETTING_LOCALE);
    return locale.isEmpty ? 'zh' : locale;
  }

  // 保存语言设置
  static void setLocale(String? locale) {
    setString(_SETTING_LOCALE, locale);
  }

  static String getString(String key) {
    String? value = _prefs?.getString(key);
    Log.d('get $key=$value', tag: _TAG);
    return value ?? '';
  }

  static void setString(String key, String? value) {
    _prefs?.setString(key, value ?? '').then((res) => Log.d('$key=$value', tag: _TAG));
  }

  static int getInt(String key) {
    int? value = _prefs?.getInt(key);
    Log.d('get $key=$value', tag: _TAG);
    return value ?? 0;
  }

  static void setInt(String key, int? value) {
    _prefs?.setInt(key, value ?? 0).then((res) => Log.d('$key=$value', tag: _TAG));
  }

  static bool getBool(String key) {
    bool? value = _prefs?.getBool(key);
    Log.d('get $key=$value', tag: _TAG);
    return value ?? false;
  }

  static void setBool(String key, bool? value) {
    _prefs?.setBool(key, value ?? false).then((res) => Log.d('$key=$value', tag: _TAG));
  }
}
