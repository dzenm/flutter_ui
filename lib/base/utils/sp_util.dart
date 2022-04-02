import 'package:flutter_ui/base/log/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

///
/// Created by a0010 on 2022/3/22 09:38
/// SharedPreferences工具类
///
class SpUtil {
  SpUtil._internal();

  static final SpUtil _getInstance = SpUtil._internal();

  static SpUtil get getInstance => _getInstance;

  static SharedPreferences? _prefs;

  static const String _tag = 'SP数据';

  static const String _userInfo = 'u_user_info';

  static const String _isLogin = 'u_is_login';
  static const String _user = 'u_user';
  static const String _userName = 'u_username';
  static const String _userId = 'u_user_id';
  static const String _userToken = 'u_token';

  static const String _settingTheme = 's_theme';
  static const String _settingLocale = 's_locale';

  Future init() async {
    _prefs = await SharedPreferences.getInstance();
    Log.d('初始化 SharedPreferences ${_prefs != null ? '成功' : '失败'}');
  }

  // 获取用户信息
  static String getUserInfo() {
    return getString(_userInfo);
  }

  // 保存用户信息
  static void setUserInfo(String? user) {
    setString(_userInfo, user);
  }

  // 是否登录信息
  static bool getIsLogin() {
    return getBool(_isLogin);
  }

  // 保存登录信息
  static void setIsLogin(bool? isLogin) {
    setBool(_isLogin, isLogin);
  }

  // 获取用户信息
  static String getUser() {
    return getString(_user);
  }

  // 保存用户信息
  static void setUser(String? user) {
    setString(_user, user);
  }

// 获取用户名
  static String getUsername() {
    return getString(_userName);
  }

  // 保存用户名
  static void setUsername(String? username) {
    setString(_userName, username);
  }

  // 获取登录用户ID
  static String getUserId() {
    return getString(_userId);
  }

  // 保存登录用户ID
  static void setUserId(String? userId) {
    setString(_userId, userId);
  }

  // 获取登录用户token
  static String getToken() {
    return getString(_userToken);
  }

  // 保存登录用户token
  static void setToken(String? token) {
    setString(_userToken, token);
  }

  // 获取主题样式
  static String getTheme() {
    String theme = getString(_settingTheme);
    return theme.isEmpty ? 'gray' : theme;
  }

  // 保存主题样式
  static void setTheme(String? theme) {
    setString(_settingTheme, theme);
  }

  // 获取语言设置
  static String getLocale() {
    String locale = getString(_settingLocale);
    return locale.isEmpty ? 'zh' : locale;
  }

  // 保存语言设置
  static void setLocale(String? locale) {
    setString(_settingLocale, locale);
  }

  static String getString(String key) {
    String? value = _prefs?.getString(key);
    Log.d('get $key=$value', tag: _tag);
    return value ?? '';
  }

  static void setString(String key, String? value) {
    _prefs?.setString(key, value ?? '').then((res) => Log.d('$key=$value', tag: _tag));
  }

  static int getInt(String key) {
    int? value = _prefs?.getInt(key);
    Log.d('get $key=$value', tag: _tag);
    return value ?? 0;
  }

  static void setInt(String key, int? value) {
    _prefs?.setInt(key, value ?? 0).then((res) => Log.d('$key=$value', tag: _tag));
  }

  static bool getBool(String key) {
    bool? value = _prefs?.getBool(key);
    Log.d('get $key=$value', tag: _tag);
    return value ?? false;
  }

  static void setBool(String key, bool? value) {
    _prefs?.setBool(key, value ?? false).then((res) => Log.d('$key=$value', tag: _tag));
  }
}
