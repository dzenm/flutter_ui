import 'package:flutter_ui/base/log/log.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences工具类
class SpUtil {
  SpUtil._internal();

  static final SpUtil _instance = SpUtil._internal();

  static SpUtil get instance => _instance;

  static SharedPreferences? _prefs;

  static const String TAG = 'SP数据';

  static const String _USER_INFO = 'user_info';

  static const String _IS_LOGIN = 'is_login';
  static const String _USER_USERNAME = 'u_username';
  static const String _USER_USER_ID = 'u_user_id';
  static const String _USER_TOKEN = 'u_token';

  Future init() async {
    _prefs = await SharedPreferences.getInstance();
    Log.d('SP初始化${_prefs != null ? '成功' : '失败'}');
  }

  // 获取用户信息
  static String getUser() {
    String user = getString(_USER_INFO);
    Log.d('getUser=$user', tag: TAG);
    return user;
  }

  // 保存用户信息
  static void setUser(String? user) {
    Log.d('setUser=$user', tag: TAG);
    setString(_USER_INFO, user);
  }

  // 是否登录信息
  static bool getIsLogin() {
    bool isLogin = getBool(_IS_LOGIN);
    Log.d('getIsLogin=$isLogin', tag: TAG);
    return isLogin;
  }

  // 保存登录信息
  static void setIsLogin(bool? isLogin) {
    Log.d('setIsLogin=$isLogin', tag: TAG);
    setBool(_IS_LOGIN, isLogin);
  }

  // 获取用户名
  static String getUsername() {
    String username = getString(_USER_USERNAME);
    Log.d('getUsername=$username', tag: TAG);
    return username;
  }

  // 保存用户名
  static void setUsername(String? username) {
    Log.d('setUsername=$username', tag: TAG);
    setString(_USER_USERNAME, username);
  }

  // 获取登录用户ID
  static String getUserId() {
    String id = getString(_USER_USER_ID);
    Log.d('getUserId=$id', tag: TAG);
    return id;
  }

  // 保存登录用户ID
  static void setUserId(String? userId) {
    Log.d('setUserId=$userId', tag: TAG);
    setString(_USER_USER_ID, userId);
  }

  // 获取登录用户token
  static String getToken() {
    String token = getString(_USER_TOKEN);
    Log.d('getToken=$token', tag: TAG);
    return token;
  }

  // 保存登录用户token
  static void setToken(String? token) {
    Log.d('setToken=$token', tag: TAG);
    setString(_USER_TOKEN, token);
  }

  static String getString(String key) {
    return _prefs?.getString(key) ?? '';
  }

  static void setString(String key, String? value) {
    _prefs?.setString(key, value ?? '');
  }

  static int getInt(String key) {
    return _prefs?.getInt(key) ?? 0;
  }

  static void setInt(String key, int? value) {
    _prefs?.setInt(key, value ?? 0);
  }

  static bool getBool(String key) {
    return _prefs?.getBool(key) ?? false;
  }

  static void setBool(String key, bool? value) {
    _prefs?.setBool(key, value ?? false);
  }
}
