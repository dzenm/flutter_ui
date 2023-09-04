import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/9/1 14:45
///
class ConsumerModel with ChangeNotifier {

  int _value = 10;

  void increment() {
    _value++;
    notifyListeners();
  }

  int get value => _value;

}