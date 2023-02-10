import 'package:shared_preferences/shared_preferences.dart';

import '../log/log.dart';

///
/// Created by a0010 on 2022/3/22 09:38
/// SharedPreferences工具类
///
class SpUtil {
  SpUtil._internal();

  static final SpUtil _getInstance = SpUtil._internal();

  static SpUtil get getInstance => _getInstance;

  static SharedPreferences? _prefs;

  static const String _tag = 'SpUtil';

  /// 用户登录相关的信息
  static const String _userInfo = 'u_info'; // 登录的用户信息
  static const String _userLoginState = 'u_login_state'; // 登录状态的信息
  static const String _user = 'u_user';
  static const String _userName = 'u_name'; // 登录的用户名
  static const String _userId = 'u_id'; // 登录的用户ID
  static const String _userToken = 'u_token'; // 登录的token信息

  /// APP设置相关的信息
  static const String _settingTheme = 's_theme'; // APP展示的主题
  static const String _settingLocale = 's_locale'; // APP展示的语言

  Future init() async {
    _prefs = await SharedPreferences.getInstance();
    Log.i('初始化 SharedPreferences ${_prefs != null ? '成功' : '失败'}', tag: _tag);
  }

  // 登录状态信息
  static bool getUserLoginState() {
    return getBool(_userLoginState);
  }

  // 保存登录状态信息
  static void setUserLoginState(bool? isLogin) {
    setBool(_userLoginState, isLogin);
  }

  // 获取用户信息
  static String getUserInfo() {
    return getString(_userInfo);
  }

  // 保存用户信息
  static void setUserInfo(String? user) {
    setString(_userInfo, user);
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

  // 重置登录用户信息
  static void resetUser() {
    remove(_userInfo);
    remove(_userLoginState);
    remove(_user);
    remove(_userId);
    remove(_userToken);
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
    Log.i('get $key=$value', tag: _tag);
    return value ?? '';
  }

  static void setString(String key, String? value) {
    _prefs?.setString(key, value ?? '').then((res) => Log.i('$key=$value', tag: _tag));
  }

  static int getInt(String key) {
    int? value = _prefs?.getInt(key);
    Log.i('get $key=$value', tag: _tag);
    return value ?? 0;
  }

  static void setInt(String key, int? value) {
    _prefs?.setInt(key, value ?? 0).then((res) => Log.i('$key=$value', tag: _tag));
  }

  static bool getBool(String key) {
    bool? value = _prefs?.getBool(key);
    Log.i('get $key=$value', tag: _tag);
    return value ?? false;
  }

  static void setBool(String key, bool? value) {
    _prefs?.setBool(key, value ?? false).then((res) => Log.i('$key=$value', tag: _tag));
  }

  static void remove(String key) {
    Log.d('remove $key=$key', tag: _tag);
    _prefs?.remove(key);
  }
}
