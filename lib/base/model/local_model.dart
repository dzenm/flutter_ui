import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../res/colors.dart';
import '../res/theme/app_theme.dart';
import '../utils/sp_util.dart';

class LocalModel with ChangeNotifier {
  /// 初始化主题设置
  LocalModel() {
    _theme = SpUtil.getTheme();
    _locale = Locale(SpUtil.getLocale());
  }

  /// 当前设置的主题
  late String _theme;

  String get theme => _theme;

  void setTheme(String theme) {
    _theme = theme;
    SpUtil.setTheme(theme);
    notifyListeners();
  }

  /// 当前设置的语言
  late Locale _locale;

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    SpUtil.setLocale(locale.languageCode);
    notifyListeners();
  }

  /// 获取设置的主题包
  AppTheme get appTheme => C.getTheme(theme);

  String _value = 'init value';

  String get value => _value;

  void setValue(String value) {
    _value = value;
    notifyListeners();
  }
}
