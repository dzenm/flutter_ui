import 'package:flutter/widgets.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// Provider中共享的Me页面数据
class MeModel with ChangeNotifier {
  /// 初始化数据
  Future<void> init() async {}

  String _ip = 'IP';

  String get ip => _ip;

  void updateIP(String ip) {
    _ip = ip;
    notifyListeners();
  }

  /// 桌面端选中的页面
  String? get selectedTab => _selectedTab;
  String? _selectedTab;

  set selectedTab(String? tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  String _text = '测试数据';

  String get text => _text;

  void updateText(String text) {
    _text = text;
    notifyListeners();
  }


  /// 清空数据
  void clear() {
    notifyListeners();
  }
}
