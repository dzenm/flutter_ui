import 'package:flutter/widgets.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// Provider中共享的Home页面数据
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
