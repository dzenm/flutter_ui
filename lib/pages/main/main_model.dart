import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../main.dart';

class MainModel with ChangeNotifier {
  static MainModel get of => Provider.of<MainModel>(Application.context, listen: false);

  int _homeCount = -1;

  int get homeCount => _homeCount;

  void changeHomeCount(int count) {
    _homeCount = count;
    notifyListeners();
  }

  void addHomeCount(int count) {
    if (_homeCount + count > 0) {
      _homeCount += count;
    }
    notifyListeners();
  }

  void reduceHomeCount(int count) {
    if (_homeCount - count < 0) {
      _homeCount = -1;
    } else {
      _homeCount -= count;
    }
    notifyListeners();
  }

  int _meCount = 5;

  int get meCount => _meCount;

  void changeMeCount(int count) {
    _meCount = count;
    notifyListeners();
  }

  void addMeCount(int count) {
    if (_meCount + count > 0) {
      _meCount += count;
    }
    notifyListeners();
  }

  void reduceMeCount(int count) {
    if (_meCount - count < 0) {
      _meCount = -1;
    } else {
      _meCount -= count;
    }
    notifyListeners();
  }
}
