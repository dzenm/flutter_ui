import 'package:flutter/widgets.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// Provider中共享的Nav页面数据
class NavModel with ChangeNotifier {
  /// 初始化数据
  Future<void> init() async {
  }

  List<String> _tabs = ['1', '2', '3'];

  List<String> get tabs => _tabs;

  /// 清空数据
  void clear() {
    notifyListeners();
  }
}
