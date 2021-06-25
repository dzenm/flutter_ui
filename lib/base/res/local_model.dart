import 'package:flutter/widgets.dart';
import 'package:flutter_ui/utils/sp_util.dart';

class LocalModel with ChangeNotifier {

  // 主题设置
  String _theme = SpUtil.getTheme();

  String get theme => _theme;

  setTheme(String theme) {
    _theme = theme;
    SpUtil.setTheme(theme);
    notifyListeners();
  }

  // 语言设置
  Locale _locale = Locale(SpUtil.getLocale());

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    _locale = locale;
    SpUtil.setLocale(locale.languageCode);
    notifyListeners();
  }
}
