import 'package:flutter/material.dart';
import 'package:flutter_ui/base/res/strings.dart';

///
/// Created by a0010 on 2022/7/28 10:56
/// Provider中共享的主页页面数据
class MainModel with ChangeNotifier {
  /// 主页Tab长度固定为3
  int _len = 3;

  /// 获取主页Tab长度
  int get len => _len;

  /// 主页底部按钮的标题列表
  List<String> _titles = [];

  void initData(BuildContext context) {
    _titles = [
      S.of(context).home,
      S.of(context).nav,
      S.of(context).me,
    ];
  }

  /// 初始化数据
  Future<void> init() async {
  }

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
  List<IconData> _icons = [
    Icons.home,
    Icons.airplay_rounded,
    Icons.person,
  ];

  /// 根据索引获取底部按钮的图标
  IconData icon(int index) => _icons[index];

  /// 主页底部的小红点数量列表
  List<int> _badgeLists = List.generate(3, (index) => index * index * index);

  /// 根据索引获取底部按钮的小红点数量
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

  /// 主页选中的item索引，默认为第一个
  int _selectIndex = 0;

  /// 获取当前选中的item索引
  int get selectIndex => _selectIndex;

  /// 根据索引判断索引是否是选中的索引
  bool isSelected(int index) {
    return _selectIndex == index;
  }

  /// 更新当前选中的item索引
  set selectIndex(int selectIndex) {
    if (_selectIndex == selectIndex) return;
    _selectIndex = selectIndex;
    notifyListeners();
  }

  /// 清空数据
  void clear() {
    _selectIndex = 0;
    notifyListeners();
  }
}
