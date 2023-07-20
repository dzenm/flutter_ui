import 'package:flutter/material.dart';

import '../utils/sp_util.dart';
import 'app_theme.dart';

///
/// Created by a0010 on 2022/3/22 09:38
/// 本地resource共享的数据
class LocalModel with ChangeNotifier {
  /// 初始化主题设置
  LocalModel() {
    _themeMode = _getMode(SpUtil.getTheme());
    _locale = Locale(SpUtil.getLocale());
  }

  /// 当前设置的主题模式
  late AppThemeMode _themeMode;

  /// 获取当前设置的主题模式
  AppThemeMode get themeMode => _themeMode;

  /// 设置新的主题模式
  void setThemeMode(AppThemeMode themeMode) {
    _themeMode = themeMode;
    SpUtil.setTheme(themeMode.name);
    notifyListeners();
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
    SpUtil.setLocale(locale.languageCode);
    notifyListeners();
  }

  Map<AppThemeMode, AppTheme> _appThemes = AppTheme.appTheme;

  AppThemeMode _getMode(String name) {
    AppThemeMode mode = AppThemeMode.light;
    AppThemeMode.values.forEach((value) {
      if (value.name == name) mode = value;
    });
    return mode;
  }

  AppTheme getTheme(AppThemeMode mode) => _appThemes[mode]!;

  List<AppThemeMode> get themes => _appThemes.keys.toList();
}
