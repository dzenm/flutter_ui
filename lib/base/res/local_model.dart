import 'package:flutter/widgets.dart';

class LocalModel extends ChangeNotifier {
  String _themeColor = 'blue';

  String get themeColor => _themeColor;

  setTheme(String themeColor) {
    _themeColor = themeColor;
    notifyListeners();
  }
}
