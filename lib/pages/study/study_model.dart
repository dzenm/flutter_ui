import 'package:flutter/material.dart';

///
/// Created by a0010 on 2022/11/3 16:14
///
class StudyModel with ChangeNotifier {
  String _value = 'default';

  String get value => _value;

  /// 初始化数据
  Future<void> init() async {
  }

  void setValue(String value) {
    _value = value;
    notifyListeners();
  }

  /// 清空数据
  void clear() {
    notifyListeners();
  }
}
