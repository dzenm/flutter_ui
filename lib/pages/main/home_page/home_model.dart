import 'package:flutter/widgets.dart';

class HomeModel with ChangeNotifier {
  /// 初始化数据
  Future<void> init() async {
    notifyListeners();
  }

  /// 清空数据
  void clear() {
    notifyListeners();
  }
}
