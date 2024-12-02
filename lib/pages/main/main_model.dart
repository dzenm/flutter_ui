import 'package:flutter/material.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// Provider中共享的主页页面数据
class MainModel with ChangeNotifier {
  /// 初始化数据
  Future<void> init() async {
    _initial = false;
    _tabItems.clear();
    for (var tab in MainTab.values) {
      int count = tab.index >= 2 ? -1 : tab.index;
      _tabItems[tab] = _MainItem(badge: count);
    }
  }

  /// 主页是否初始化完成
  bool get initial => _initial;
  bool _initial = false;
  void initialComplete() {
    _initial = true;
    notifyListeners();
  }

  final Map<MainTab, _MainItem> _tabItems = {};

  /// 获取当前选中的Tab
  MainTab get selectedTab {
    MainTab tab = MainTab.home;
    _tabItems.forEach((key, item) {
      if (item.isSelected) tab = key;
    });
    return tab;
  }

  /// 更新当前选中的Tab
  void setSelectedTab(MainTab tab) {
    if (selectedTab == tab) return;
    _tabItems.forEach((key, item) {
      item.isSelected = tab == key;
    });
    notifyListeners();
  }

  /// 根据索引判断索引是否是选中的Tab
  bool isSelected(MainTab tab) => selectedTab == tab;

  /// 根据索引获取底部按钮的小红点数量
  int badge(MainTab tab) => _tabItems[tab]!.badge;

  void addCount(MainTab tab, int count) {
    if (_tabItems[tab]!.badge + count > 0) {
      _tabItems[tab]!.badge += count;
    }
    notifyListeners();
  }

  void reduceCount(MainTab tab, int count) {
    int totalCount = _tabItems[tab]!.badge - count;
    _tabItems[tab]!.badge = totalCount < 0 ? -1 : totalCount;
    notifyListeners();
  }

  /// 是否正在拖动文件
  bool _isDragFile = false;

  bool get isDragFile => _isDragFile;

  set isDragFile(bool isDragFile) {
    _isDragFile = isDragFile;
    notifyListeners();
  }

  /// 清空数据
  void clear() {
    _initial = false;
    notifyListeners();
  }
}

class _MainItem {
  bool isSelected = false;
  int badge = -1;

  _MainItem({
    this.isSelected = false,
    this.badge = -1,
  });
}

/// 主页导航栏
enum MainTab {
  home,
  nav,
  me,
}
