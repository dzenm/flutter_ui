import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// Provider中共享的主页页面数据
class MainModel with ChangeNotifier {
  /// 初始化数据
  Future<void> init() async {}

  void initData(BuildContext context) {
    _titles = [
      S.of(context).home,
      S.of(context).nav,
      S.of(context).me,
    ];
    _icons = [
      Icons.home,
      Icons.airplay_rounded,
      Icons.person,
    ];
    // _badges = List.generate(3, (index) => index * index * index);
    _badges = [-1, 0, 5];
    _selectedIndex = 0;
  }

  /// 获取主页Tab长度
  int get len => _titles.length;

  /// 主页底部按钮的标题列表
  List<String> _titles = [];

  /// 获取底部按钮的标题列表
  List<String> get titles => _titles;

  /// 更新底部按钮的标题列表
  set titles(List<String> titles) {
    _titles = titles;
    notifyListeners();
  }

  /// 根据索引获取底部按钮的标题
  String title(int index) => _titles[index];

  /// 主页底部按钮的图标列表
  List<IconData> _icons = [];

  /// 获取底部按钮的图标列表
  List<IconData> get icons => _icons;

  /// 更新底部按钮的图标列表
  set icons(List<IconData> icons) {
    _icons = icons;
    notifyListeners();
  }

  /// 根据索引获取底部按钮的图标
  IconData icon(int index) => _icons[index];

  /// 主页底部的小红点数量列表
  List<int> _badges = [];

  /// 根据索引获取底部按钮的小红点数量
  int badge(int index) => _badges[index];

  void addCount(int index, int count) {
    if (_badges[index] + count > 0) {
      _badges[index] += count;
    }
    notifyListeners();
  }

  void reduceCount(int index, int count) {
    int totalCount = _badges[index] - count;
    _badges[index] = totalCount < 0 ? -1 : totalCount;
    notifyListeners();
  }

  /// 主页选中的item索引，默认为第一个
  int _selectedIndex = 0;

  /// 获取当前选中的item索引
  int get selectedIndex => _selectedIndex;

  /// 根据索引判断索引是否是选中的索引
  bool isSelected(int index) => _selectedIndex == index;

  /// 更新当前选中的item索引
  set selectedIndex(int selectedIndex) {
    if (_selectedIndex == selectedIndex) return;
    _selectedIndex = selectedIndex;
    notifyListeners();
  }

  /// 清空数据
  void clear() {
    _selectedIndex = 0;
    notifyListeners();
  }
}
