import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/res/colors.dart';
import 'package:flutter_ui/base/utils/sp_util.dart';

class LocalModel extends ChangeNotifier {
  LocalModel() {
    _theme = SpUtil.getTheme();
    _locale = Locale(SpUtil.getLocale());
  }

  /// 主题设置
  late String _theme;

  String get theme => _theme;

  void setTheme(String theme) {
    _theme = theme;
    SpUtil.setTheme(theme);
    notifyListeners();
  }

  ///
  AppTheme get appTheme => themeModel[_theme]!;

  /// 语言设置
  late Locale _locale;

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    SpUtil.setLocale(locale.languageCode);
    notifyListeners();
  }

  String _value = 'init value';

  String get value => _value;

  void setValue(String value) {
    _value = value;
    notifyListeners();
  }
}
