import 'package:flutter/material.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// Provider中共享的主页页面数据
class MainModel with ChangeNotifier {
  /// 主页是否初始化完成
  bool _initial = false;

  bool get initial => _initial;

  void initialComplete() {
    _initial = true;
    notifyListeners();
  }

  /// 初始化数据
  Future<void> init() async {
    _badges = List.generate(3, (index) => 0);
    _controller = PageController(initialPage: _selectedIndex);
  }

  /// 首页面切换的PageController
  PageController? _controller;

  PageController get controller => _controller!;

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
    _controller?.animateToPage(
      selectedIndex,
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
    );
    notifyListeners();
  }

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

  /// 获取主页Tab长度
  int get length => _badges.length;

  /// 清空数据
  void clear() {
    _selectedIndex = 0;
    _controller?.dispose();
    _controller = null;
    _badges.clear();
    notifyListeners();
  }
}
