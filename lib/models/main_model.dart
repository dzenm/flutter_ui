import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../main.dart';

class MainModel with ChangeNotifier {
  static MainModel get of => Provider.of<MainModel>(navigator.currentContext!, listen: false);

  int _homeCount = -1;

  int get homeCount => _homeCount;

  void addHomeCount(int count) {
    if (_homeCount < -1 && count > 0) _homeCount = 0;
    _homeCount += count;
    notifyListeners();
  }

  int _meCount = 5;

  int get meCount => _meCount;

  void addMeCount(int count) {
    if (_meCount < -1 && count > 0) _meCount = 0;
    _meCount += count;
    notifyListeners();
  }
}
