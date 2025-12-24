import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'location.dart';

const double _kPickerHeight = 220.0;
const double _kPickerTitleHeight = 44.0;
const double _kPickerItemHeight = 40.0;

/// 列表选择器
class PickerView<T> extends StatefulWidget {
  final List<PickerEntity<T>> pickers;
  final List<String>? initialPicker;
  final List<String>? labels;
  final Widget Function(BuildContext context, PickerEntity<T> item)? itemBuilder;
  final PopupRoute<List<PickerEntity<T>>> popupRoute;
  final ValueChanged<List<PickerEntity<T>>>? onChanged;

  const PickerView({
    super.key,
    required this.pickers,
    this.initialPicker,
    this.labels,
    this.itemBuilder,
    required this.popupRoute,
    this.onChanged,
  });

  static Future<List<PickerEntity<T>>?> show<T>(
    BuildContext context, {
    required List<PickerEntity<T>> list,
    List<String>? initialItem,
    List<String>? labels,
    ValueChanged<List<String>>? onChanged,
  }) async {
    return await showDialog<T>(
      context,
      list: list,
      initialItem: initialItem,
      labels: labels,
      onChanged: onChanged == null //
          ? null
          : (list) => onChanged(list.map((e) => e.name ?? '').toList()),
    );
  }

  /// 选择地区
  /// PickerView.showLocation(
  ///   context,
  ///   initialItem: ['湖北', '荆门市', '京山县'],
  ///   onChanged: (results) {
  ///     Log.d('选中的结果: results=$results');
  ///   }
  /// )
  static Future<List<PickerEntity>?> showLocation(
    BuildContext context, {
    List<String>? initialItem,
    ValueChanged<List<String>>? onChanged,
    int maxColumn = 3,
  }) async {
    assert(maxColumn <= 3, 'maxColumn must be less than 3');
    List<PickerEntity<String>> list = _getLocation(maxColumn);
    var result = await showDialog<String>(
      context,
      list: list,
      initialItem: initialItem,
      onChanged: onChanged == null //
          ? null
          : (list) => onChanged(list.map((e) => e.name ?? '').toList()),
    );
    return result ?? [];
  }

  /// 获取位置信息的数据
  static List<PickerEntity<String>> _getLocation(int maxColumn) {
    List<PickerEntity<String>> provinceList = [];
    for (var province in locations) {
      // 添加省份信息
      List<PickerEntity<String>> cityList = [];
      provinceList.add(PickerEntity<String>(
        name: province['name'] ?? '',
        list: cityList,
      ));
      if (maxColumn == 1) continue;

      List<dynamic> cities = province['cityList'] ?? [];
      for (var city in cities) {
        List<PickerEntity<String>> areaList = [];
        bool showCity = maxColumn == 2 && city['name'] != null;
        if (maxColumn == 3 || showCity) {
          // 添加城市信息
          cityList.add(PickerEntity(
            name: city['name'] ?? '',
            list: areaList,
          ));
          if (showCity) continue;
        }
        showCity = maxColumn == 2 && city['name'] == null;
        List<dynamic> areas = city['areaList'] ?? [];
        for (var area in areas) {
          // 添加区域信息
          (showCity ? cityList : areaList).add(PickerEntity(name: area));
        }
      }
    }
    return provinceList;
  }

  /// 列表下拉选择器
  /// PickerView.showList(
  ///   context,
  ///   list: ['测试一', '测试二', '测试三', '测试四', '测试五'],
  ///   initialItem: _selectedValue,
  ///   onChanged: (value) {
  ///     _selectedValue = value;
  ///     Log.i('选中的回调: $_selectedValue');
  ///   },
  /// )
  static Future<String?> showList(
    BuildContext context, {
    required List<String> list,
    String? initialItem,
    ValueChanged<String>? onChanged,
  }) async {
    var result = await showDialog<String>(
      context,
      list: list.map((item) => PickerEntity<String>(name: item)).toList(),
      initialItem: initialItem == null ? null : [initialItem],
      onChanged: onChanged == null ? null : (list) => onChanged(list[0].name ?? ''),
    );
    if (result == null || result.isEmpty) return null;
    return result.first.name ?? "";
  }

  static Future<List<PickerEntity<I>>?> showDialog<I>(
    BuildContext context, {
    bool barrierDismissible = true,
    required List<PickerEntity<I>> list,
    List<String>? initialItem,
    List<String>? labels,
    Widget Function(BuildContext context, PickerEntity<I> item)? itemBuilder,
    ValueChanged<List<PickerEntity<I>>>? onChanged,
  }) async {
    return await Navigator.push<List<PickerEntity<I>>>(
      context,
      PickerPopupRoute<List<PickerEntity<I>>>(
          barrierDismissible: barrierDismissible,
          theme: Theme.of(context),
          barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
          pageBuilder: (pageRoute) {
            return PickerView<I>(
              pickers: list,
              initialPicker: initialItem,
              labels: labels,
              itemBuilder: itemBuilder,
              popupRoute: pageRoute,
              onChanged: onChanged,
            );
          }),
    );
  }

  // 获取所有城市名称
  static List<String> getAllCities() {
    List<String> cityList = [];
    List cities = locations.map((item) {
      String province = item['name']; // 省
      List? cityNames = item['cityList'];
      if ((cityNames?.isEmpty ?? true) || cityNames!.where((element) => element['name'] != null).toList().isEmpty) {
        return [province]; // 无城市 - 默认省
      }

      List<String> proCityList = [];
      for (var cityItem in cityNames) {
        if (cityItem['name'] != null) {
          proCityList.add(cityItem['name']);
        }
      }
      return proCityList;
    }).toList();

    for (var element in cities) {
      cityList.addAll(element);
    }

    return cityList;
  }

  @override
  State<PickerView<T>> createState() => _PickerViewState<T>();
}

/// 列表选择器的状态
class _PickerViewState<T> extends State<PickerView<T>> {
  List<PickerEntity<T>> _list = [];
  List<int> _selectedIndexes = [];
  List<FixedExtentScrollController> _controllers = [];
  int _len = 0;

  @override
  void initState() {
    super.initState();

    // 获取数据
    _list = widget.pickers;
    _len = _getMaxLevel(0, _list);

    // 初始化选中的下标
    _selectedIndexes = List.generate(_len, (index) => 0);
    List<PickerEntity<T>>? data = _list;
    List<String> names = widget.initialPicker ?? [];
    for (int i = 0; i < names.length; i++) {
      // 数据为空不处理
      if (data == null || data.isEmpty) continue;
      // 在当前数据列表找到对应数据的下标
      for (int j = 0; j < data!.length; j++) {
        // 如果数据不相等/数据为空的情况默认为选中第一个
        if (names[i] != data[j].name || names[i].isEmpty) continue;
        _selectedIndexes[i] = j;
        data = data[j].list;
        break;
      }
    }
    _controllers = List.generate(
      _len,
      (index) => FixedExtentScrollController(initialItem: _selectedIndexes[index]),
    );
  }

  /// 获取List的最大深度
  int _getMaxLevel(int level, List<PickerEntity<T>> list) {
    if (list.isNotEmpty && list.first.list == null) {
      return level + 1;
    }
    int maxLevel = level;
    for (int i = 0; i < list.length; i++) {
      int value = _getMaxLevel(level + 1, list[i].list!);
      maxLevel = max(value, maxLevel);
    }
    return maxLevel;
  }

  @override
  Widget build(BuildContext context) {
    var animation = widget.popupRoute.animation;
    if (animation == null) {
      return const SizedBox.shrink();
    }
    return GestureDetector(
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return ClipRect(
            child: CustomSingleChildLayout(
              delegate: _BottomPickerLayout(animation.value),
              child: GestureDetector(
                child: Material(
                  color: Colors.transparent,
                  child: Column(children: [
                    _buildTitleActionsView(),
                    _buildPickerListView(),
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Title View
  Widget _buildTitleActionsView() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SizedBox(
          height: _kPickerTitleHeight,
          child: TextButton(
            child: Text(
              '取消',
              style: TextStyle(
                color: Theme.of(context).unselectedWidgetColor,
                fontSize: 16.0,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        SizedBox(
          height: _kPickerTitleHeight,
          child: TextButton(
            child: Text(
              '确定',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 16.0,
              ),
            ),
            onPressed: () {
              List<int> indexes = _selectedIndexes;
              List<PickerEntity<T>> data = _list;
              List<PickerEntity<T>> results = [];
              for (var index in indexes) {
                PickerEntity<T> item = data[index];
                results.add(item);
                data = item.list ?? [];
              }
              widget.onChanged?.call(results);
              Navigator.pop<List<PickerEntity<T>>>(context, results);
            },
          ),
        ),
      ]),
    );
  }

  /// 选择布局列表
  Widget _buildPickerListView() {
    var indexes = _selectedIndexes;
    List<Widget> widgets = [];
    widgets.add(const SizedBox(width: 10));
    for (int level = 0; level < indexes.length; level++) {
      // 根据层级数找到对应展示的List
      var list = _list;
      int j = 0;
      while (true) {
        if (j == level) break;
        list = list[indexes[j++]].list ?? [];
      }
      widgets.add(Expanded(child: _buildSinglePickerView(level, list)));
      // 单位名称
      var labels = widget.labels;
      if (labels == null) continue;
      String? label = level < labels.length ? labels[level] : null;
      if (label == null) continue;
      widgets.add(const SizedBox(width: 4));
      widgets.add(Text(label));
      widgets.add(const SizedBox(width: 4));
    }
    widgets.add(const SizedBox(width: 10));
    return Container(
      height: _kPickerHeight,
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(children: widgets),
    );
  }

  /// 单个选择列表的布局
  /// [index] 单个列表所在的下标
  /// [list] 单个选择列表布局对应展示的数据列表
  Widget _buildSinglePickerView(int index, List<PickerEntity<T>> list) {
    List<Widget> widgets = [];
    for (int i = 0; i < list.length; i++) {
      PickerEntity<T> item = list[i];
      widgets.add((widget.itemBuilder ?? _buildPickerItemView).call(context, item));
    }
    return Container(
      height: _kPickerHeight,
      decoration: const BoxDecoration(color: Colors.white),
      child: CupertinoPicker(
        backgroundColor: Colors.white,
        scrollController: _controllers[index],
        itemExtent: _kPickerItemHeight,
        onSelectedItemChanged: (int i) => _update(index, list, i),
        children: widgets,
      ),
    );
  }

  /// 选择列表的子布局
  Widget _buildPickerItemView(BuildContext context, PickerEntity<T> item) {
    String text = item.name ?? '';
    return Container(
      height: _kPickerItemHeight,
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: const Color(0xFF000046),
          fontSize: _pickerFontSize(text),
        ),
        textAlign: TextAlign.start,
      ),
    );
  }

  /// 文本的字体大小
  double _pickerFontSize(String text) {
    double ratio = 0;
    if (text.length <= 6) {
      return 18.0;
    }
    if (text.length < 9) {
      return 16.0 + ratio;
    }
    if (text.length < 13) {
      return 12.0 + ratio;
    }
    return 10.0 + ratio;
  }

  /// 更新数据
  void _update(int index, List list, int i) {
    for (int i = index + 1; i < _len; i++) {
      _selectedIndexes[i] = 0;
      _controllers[i].jumpToItem(0);
    }
    _selectedIndexes[index] = i;
    setState(() {});
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}

/// Popup弹入弹出的动画
class PickerPopupRoute<T> extends PopupRoute<T> {
  final Widget Function(PopupRoute<T> pageRoute) pageBuilder;
  final ThemeData theme;
  final bool _barrierDismissible;

  PickerPopupRoute({
    required this.pageBuilder,
    required this.theme,
    bool barrierDismissible = true,
    required this.barrierLabel,
  }) : _barrierDismissible = barrierDismissible;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => _barrierDismissible;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: pageBuilder.call(this),
    );
    bottomSheet = Theme(data: theme, child: bottomSheet);
    return bottomSheet;
  }
}

/// Picker展示的数据
class PickerEntity<T> {
  String? name;
  List<PickerEntity<T>>? list;
  T? data;

  PickerEntity({this.name, this.list, this.data});
}

class _BottomPickerLayout extends SingleChildLayoutDelegate {
  _BottomPickerLayout(this.progress);

  final double progress;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    double maxHeight = _kPickerHeight;
    maxHeight += _kPickerTitleHeight;
    return BoxConstraints(
      minWidth: constraints.maxWidth,
      maxWidth: constraints.maxWidth,
      minHeight: 0.0,
      maxHeight: maxHeight,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double height = size.height - childSize.height * progress;
    return Offset(0.0, height);
  }

  @override
  bool shouldRelayout(_BottomPickerLayout oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
