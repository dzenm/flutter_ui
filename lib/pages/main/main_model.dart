import 'package:flutter/material.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// Provider中共享的主页页面数据
class MainModel with ChangeNotifier {
  /// 初始化数据
  Future<void> init() async {
    _initial = false;
    _selectedTab = MainTab.home;
    _items.clear();
    for (var tab in MainTab.values) {
      _items[tab] = MainItem();
    }
  }

  /// 主页是否初始化完成
  bool _initial = false;

  bool get initial => _initial;

  void initialComplete() {
    _initial = true;
    notifyListeners();
  }

  /// 主页选中的Tab，默认为第一个
  MainTab _selectedTab = MainTab.home;

  /// 获取当前选中的Tab
  MainTab get selectedTab => _selectedTab;

  /// 更新当前选中的Tab
  set selectedTab(dynamic selectedTab) {
    if (selectedTab is MainTab) {
      if (_selectedTab == selectedTab) return;
      _selectedTab = selectedTab;
    } else if (selectedTab is int) {
      if (_selectedTab.index == selectedTab) return;
      for (var tab in MainTab.values) {
        if (selectedTab != tab.index) continue;
        _selectedTab = tab;
      }
    }
    notifyListeners();
  }

  /// 根据索引判断索引是否是选中的Tab
  bool isSelected(MainTab tab) => _selectedTab == tab;

  final Map<MainTab, MainItem> _items = {};

  /// 根据索引获取底部按钮的小红点数量
  int badge(MainTab tab) => _items[tab]!.badge;

  void addCount(MainTab tab, int count) {
    if (_items[tab]!.badge + count > 0) {
      _items[tab]!.badge += count;
    }
    notifyListeners();
  }

  void reduceCount(MainTab tab, int count) {
    int totalCount = _items[tab]!.badge - count;
    _items[tab]!.badge = totalCount < 0 ? -1 : totalCount;
    notifyListeners();
  }

  /// 获取主页Tab长度
  int get length => _items.length;

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
    _selectedTab = MainTab.home;
    notifyListeners();
  }
}

class MainItem {
  bool isSelected = false;
  int badge = 0;
}

/// 主页导航栏
enum MainTab {
  home,
  nav,
  me,
}
