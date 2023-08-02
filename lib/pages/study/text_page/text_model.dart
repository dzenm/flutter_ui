import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/7/31 14:12
///
class TextModel with ChangeNotifier {

  int _value = -1;

  void add() {
    _value++;
    notifyListeners();
  }

  int get value => _value;

  @override
  void dispose() {
    super.dispose();
    _value = -1;
  }
}