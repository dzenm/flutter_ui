import 'package:flutter/widgets.dart';
import 'package:flutter_ui/main.dart';
import 'package:flutter_ui/utils/sp_util.dart';
import 'package:provider/provider.dart';

class LocalModel with ChangeNotifier {
  static LocalModel get of => Provider.of<LocalModel>(Application.context, listen: false);

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

  String _value = 'init value';

  String get value => _value;

  void setValue(String value) {
    _value = value;
    notifyListeners();
  }
}
