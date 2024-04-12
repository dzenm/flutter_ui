import 'dart:convert';

import 'package:flutter/material.dart';

import '../db/db.dart';
import 'setting_entity.dart';
import 'app_theme.dart';

///
/// Created by a0010 on 2022/3/22 09:38
/// 本地resource共享的数据
class LocalModel with ChangeNotifier {
  /// 初始化主题设置
  LocalModel() {
    _initSetting();
    _themeMode = _getMode(_setting.theme ?? 'blue');
    _locale = Locale(_setting.locale ?? 'zh');
  }

  /// 初始化设置
  void _initSetting() {
    String settings = SPManager.getSettings();
    if (settings.isEmpty) {
      _setting = SettingEntity();
    } else {
      _setting = SettingEntity.fromJson(jsonDecode(settings));
    }
  }

  late SettingEntity _setting;

  /// 获取设置
  SettingEntity get setting => _setting;

  /// 更新设置
  void updateSetting() {
    String settings = jsonEncode(_setting.toJson());
    SPManager.setSettings(settings);
    notifyListeners();
  }

  /// 当前设置的主题模式
  late AppThemeMode _themeMode;

  /// 获取当前设置的主题模式
  AppThemeMode get themeMode => _themeMode;

  /// 设置新的主题模式
  void setThemeMode(AppThemeMode themeMode) {
    _themeMode = themeMode;
    _setting.theme = themeMode.name;
    updateSetting();
  }

  /// 获取设置的主题包
  AppTheme get theme => getTheme(_themeMode);

  /// 当前设置的语言
  late Locale _locale;

  /// 获取当前设置的语言
  Locale get locale => _locale;

  /// 设置新的语言
  void setLocale(Locale locale) {
    _locale = locale;
    _setting.locale = locale.languageCode;
    updateSetting();
  }

  final Map<AppThemeMode, AppTheme> _appThemes = AppTheme.appTheme;

  AppThemeMode _getMode(String name) {
    AppThemeMode mode = AppThemeMode.light;
    for (var value in AppThemeMode.values) {
      if (value.name == name) mode = value;
    }
    return mode;
  }

  AppTheme getTheme(AppThemeMode mode) => _appThemes[mode]!;

  List<AppThemeMode> get themes => _appThemes.keys.toList();
}
