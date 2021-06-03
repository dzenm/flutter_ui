import 'package:flutter/widgets.dart';

class LocalModel extends ChangeNotifier {
  String _themeColor = 'purple';

  String get themeColor => _themeColor;

  setTheme(String themeColor) {
    _themeColor = themeColor;
    notifyListeners();
  }
}
