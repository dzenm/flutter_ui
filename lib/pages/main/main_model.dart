import 'package:flutter/material.dart';
import 'package:flutter_ui/base/res/strings.dart';

class MainModel extends ChangeNotifier {
  /// 主页底部按钮的标题
  List<String> _titles = [];

  void init(BuildContext context) {
    _titles = [
      S.of(context).home,
      S.of(context).nav,
      S.of(context).me,
    ];
  }

  List<String> get titles => _titles;

  String title(int index) => _titles[index];

  /// 主页底部按钮的图标
  List<IconData> _icons = [
    Icons.home,
    Icons.airplay_rounded,
    Icons.person,
  ];

  IconData icon(int index) => _icons[index];

  /// 主页底部小红点的数量
  List<int> _badgeLists = [0, 65, 8];

  int badgeCount(int index) => _badgeLists[index];

  void addCount(int index, int count) {
    if (_badgeLists[index] + count > 0) {
      _badgeLists[index] += count;
    }
    notifyListeners();
  }

  void reduceCount(int index, int count) {
    int totalCount = _badgeLists[index] - count;
    _badgeLists[index] = totalCount < 0 ? -1 : totalCount;
    notifyListeners();
  }

  /// 主页选中的item索引
  int _selectIndex = 0;

  int get selectIndex => _selectIndex;

  bool isSelected(int index) {
    return _selectIndex == index;
  }

  void updateSelectIndex(int selectIndex) {
    _selectIndex = selectIndex;
    notifyListeners();
  }
}
