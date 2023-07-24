import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'location.dart';

const double _kPickerHeight = 220.0;
const double _kPickerTitleHeight = 44.0;
const double _kPickerItemHeight = 40.0;

/// 列表选择器
class PickerView<T> extends StatefulWidget {
  final List<PickerItem> list;
  final List<String>? initialItem;
  final IndexedWidgetBuilder? itemBuilder;
  final PickerPopupRoute route;
  final ValueChanged<List<dynamic>>? onChanged;

  const PickerView({super.key,
    required this.list,
    this.initialItem,
    this.itemBuilder,
    required this.route,
    this.onChanged,
  });

  /// 选择地区
  /// PickerView.showLocation(
  ///   context,
  ///   initialItem: ['湖北', '荆门市', '京山县'],
  ///   onChanged: (results) {
  ///     Log.d('选中的结果: results=$results');
  ///   }
  /// )
  static void showLocation(BuildContext context, {
    List<String>? initialItem,
    ValueChanged<List<dynamic>>? onChanged,
    int maxColumn = 3,
  }) {
    List<PickerItem> list = _getLocation(maxColumn);

    Navigator.push(
      context,
      PickerPopupRoute<String>(
        list: list,
        initialItem: initialItem,
        onChanged: onChanged,
        theme: Theme.of(context),
        barrierLabel: MaterialLocalizations
            .of(context)
            .modalBarrierDismissLabel,
      ),
    );
  }

  /// 获取位置信息的数据
  static List<PickerItem> _getLocation(int maxColumn) {
    List<PickerItem> provinceList = [];
    for (var province in locations) {
      // 添加省份信息
      List<PickerItem> cityList = [];
      provinceList.add(PickerItem(
        name: province['name'] ?? '',
        list: cityList,
      ));
      if (maxColumn == 1) continue;

      List<dynamic> cities = province['cityList'] ?? [];
      for (var city in cities) {
        List<PickerItem> areaList = [];
        bool showCity = maxColumn == 2 && city['name'] != null;
        if (maxColumn == 3 || showCity) {
          // 添加城市信息
          cityList.add(PickerItem(
            name: city['name'] ?? '',
            list: areaList,
          ));
          if (showCity) continue;
        }
        showCity = maxColumn == 2 && city['name'] == null;
        List<dynamic> areas = city['areaList'] ?? [];
        for (var area in areas) {
          // 添加区域信息
          (showCity ? cityList : areaList).add(PickerItem(name: area));
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
  static void showList(BuildContext context, {
    required List<String> list,
    String? initialItem,
    ValueChanged<String>? onChanged,
  }) {
    Navigator.push(
      context,
      PickerPopupRoute<String>(
        list: list.map((item) => PickerItem(name: item)).toList(),
        initialItem: initialItem == null ? null : [initialItem],
        onChanged: onChanged == null ? null : (list) => onChanged(list[0]),
        theme: Theme.of(context),
        barrierLabel: MaterialLocalizations
            .of(context)
            .modalBarrierDismissLabel,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _PickerViewState();
}

/// 列表选择器的状态
class _PickerViewState<T> extends State<PickerView> {
  List<PickerItem> _list = [];
  List<int> _selectedIndexes = [];
  List<FixedExtentScrollController> _controllers = [];
  int _len = 0;

  @override
  void initState() {
    super.initState();

    // 获取数据
    _list = widget.list;
    _len = _getMaxLevel(0, _list);

    // 初始化选中的下标
    _selectedIndexes = List.generate(_len, (index) => 0);
    List<PickerItem>? data = _list;
    List<String> names = widget.initialItem ?? [];
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
    _controllers = List.generate(_len, (index) => FixedExtentScrollController(initialItem: _selectedIndexes[index]));
  }

  /// 获取List的最大深度
  int _getMaxLevel(int level, List<PickerItem> list) {
    if (list.isNotEmpty && list[0].list == null) {
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
    return GestureDetector(
      child: AnimatedBuilder(
        animation: widget.route.animation!,
        builder: (BuildContext context, Widget? child) {
          return ClipRect(
            child: CustomSingleChildLayout(
              delegate: _BottomPickerLayout(widget.route.animation!.value),
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
                color: Theme
                    .of(context)
                    .unselectedWidgetColor,
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
                color: Theme
                    .of(context)
                    .primaryColor,
                fontSize: 16.0,
              ),
            ),
            onPressed: () {
              if (widget.onChanged != null) {
                List<String> results = [];
                List<PickerItem> data = _list;
                for (var index in _selectedIndexes) {
                  PickerItem item = data[index];
                  results.add(item.name ?? '');
                  data = item.list ?? [];
                }
                widget.onChanged!(results);
              }
              Navigator.pop(context);
            },
          ),
        ),
      ]),
    );
  }

  /// 选择布局列表
  Widget _buildPickerListView() {
    List<PickerItem> getData(int i, int level, List<PickerItem> list, int index) {
      if (i == level) {
        return list;
      }
      return getData(i + 1, level, list[index].list ?? [], _selectedIndexes[i + 1]);
    }

    List<Widget> widgets = [];
    for (int i = 0; i < _len; i++) {
      widgets.add(_buildSinglePickerView(i, getData(0, i, _list, _selectedIndexes[0])));
    }
    return Container(
      height: _kPickerHeight,
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: widgets,
      ),
    );
  }

  /// 单个选择列表的布局
  /// [index] 单个列表所在的下标
  /// [list] 单个选择列表布局对应展示的数据列表
  Widget _buildSinglePickerView(int index, List<PickerItem> list) {
    List<Widget> widgets = [];
    for (int i = 0; i < list.length; i++) {
      PickerItem item = list[i];
      if (widget.itemBuilder == null) {
        widgets.add(_buildPickerItemView(item.name ?? ''));
      } else {
        widget.itemBuilder!(context, i);
      }
    }
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        height: _kPickerHeight,
        decoration: const BoxDecoration(color: Colors.white),
        child: CupertinoPicker(
          backgroundColor: Colors.white,
          scrollController: _controllers[index],
          itemExtent: _kPickerItemHeight,
          onSelectedItemChanged: (int i) => _update(index, list, i),
          children: widgets,
        ),
      ),
    );
  }

  /// 选择列表的子布局
  Widget _buildPickerItemView(String text) {
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
    } else if (text.length < 9) {
      return 16.0 + ratio;
    } else if (text.length < 13) {
      return 12.0 + ratio;
    } else {
      return 10.0 + ratio;
    }
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
}

/// Popup弹入弹出的动画
class PickerPopupRoute<T> extends PopupRoute<T> {
  final List<PickerItem> list;
  final List<String>? initialItem;
  final IndexedWidgetBuilder? itemBuilder;
  final ValueChanged<List<dynamic>>? onChanged;
  final ThemeData theme;
  final bool dismissible;

  PickerPopupRoute({
    this.dismissible = true,
    required this.list,
    this.initialItem,
    this.itemBuilder,
    this.onChanged,
    required this.theme,
    required this.barrierLabel,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => dismissible;

  @override
  final String barrierLabel;

  @override
  Color get barrierColor => Colors.black54;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    Widget bottomSheet = MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: PickerView(
        list: list,
        route: this,
        initialItem: initialItem,
        itemBuilder: itemBuilder,
        onChanged: onChanged,
      ),
    );
    bottomSheet = Theme(data: theme, child: bottomSheet);
    return bottomSheet;
  }
}

/// Picker展示的数据
class PickerItem<T> {
  String? name;
  List<PickerItem>? list;
  T? data;

  PickerItem({this.name, this.list, this.data});
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

/// TODO 待实现
// class ChatTimePicker {
//   static List<String> days = [];
//   static List<List<String>> hrs = [];
//   static List<List<List<String>>> mins = [];
//
//   static late DateTime start, end;
//
//   static void showPicker(BuildContext context, {required DateChangedCallback onConfirm, required Function onCancel}) {
//     DateTime now = DateTime.now();
//     start = now.add(Duration(minutes: 10));
//     end = DateTime(now.year, now.month, now.day + 2, 23, 59);
//
//     // print('start $start end $end');
//
//     getDateList();
//
//     Navigator.push(
//         context,
//         BasePickerRoute<String>(
//           list: [],
//           onConfirm: onConfirm,
//           dismissible: false,
//           onCancel: onCancel,
//           theme: Theme.of(context /*, shadowThemeOnly: true*/),
//           barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
//         ));
//   }
//
//   static getDateList() {
//     List<List<String>> tmpHrs = [];
//     List<List<List<String>>> tmpMins = [];
//     var formatter = DateFormat('MM-dd');
//     days = ['今天', formatter.format(start.add(Duration(days: 1))), formatter.format(start.add(Duration(days: 2)))];
//
//     for (int i = 0; i < days.length; i++) {
//       String day = days[i];
//
//       List<String> tmp_hr = List.generate(24, (index) => '${index}');
//       if ('今天' == day) {
//         tmp_hr = List.generate(24 - start.hour, (index) => '${index + start.hour}');
//       }
//       tmpHrs.add(tmp_hr);
//
//       List<List<String>> tmp_mins = [];
//       for (int j = 0; j < tmp_hr.length; j++) {
//         String hour = tmp_hr[j];
//         // List<String> tmp_min = List.generate(60, (index) => '${Utils.fillDigits(index, 2)}');
//         // if ('今天' == day && '${start.hour}' == hour) {
//         //   tmp_min = List.generate(60 - start.minute, (index) => '${Utils.fillDigits(index + start.minute, 2)}');
//         // }
//         // tmp_mins.add(tmp_min);
//       }
//       tmpMins.add(tmp_mins);
//     }
//     hrs = tmpHrs;
//     mins = tmpMins;
//   }
// }
//
// enum DateType { YMD, YM, Y }
//
// class DatePicker {
//   static List<int> years = [];
//   static List<List<int>> months = [];
//   static List<List<List<int>>> days = [];
//
//   static late DateTime start, end;
//   static late DateType dType;
//
//   static void showPicker(
//     BuildContext context, {
//     DateTime? startDate,
//     DateTime? endDate,
//     DateTime? selectDate,
//     DateType dateType = DateType.YMD,
//     required DateChangedCallback onConfirm,
//   }) {
//     DateTime now = DateTime.now();
//     selectDate ??= now;
//
//     startDate ??= DateTime(now.year - 100, 1, 1);
//     endDate ??= DateTime(now.year + 15, now.month, now.day);
//
//     start = startDate;
//     end = endDate;
//     dType = dateType;
//
//     getDateList();
//     if (dateType == DateType.Y) {
//       Navigator.push(
//         context,
//         BasePickerRoute<int>(
//           list: [],
//           onConfirm: onConfirm,
//           theme: Theme.of(context /*, shadowThemeOnly: true*/),
//           barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
//         ),
//       );
//     } else if (dateType == DateType.YM) {
//       Navigator.push(
//         context,
//         BasePickerRoute<int>(
//           list: [],
//           onConfirm: onConfirm,
//           theme: Theme.of(context /*, shadowThemeOnly: true*/),
//           barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
//         ),
//       );
//     } else {
//       Navigator.push(
//         context,
//         BasePickerRoute<int>(
//           list: [],
//           onConfirm: onConfirm,
//           theme: Theme.of(context /*, shadowThemeOnly: true*/),
//           barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
//         ),
//       );
//     }
//   }
//
//   static getDateList() {
//     List<List<int>> tmpMonths = [];
//     List<List<List<int>>> tmpDays = [];
//     int yearCount = end.year - start.year + 1;
//     years = List.generate(yearCount, (index) => start.year + index);
//
//     for (int i = 0; i < years.length; i++) {
//       int year = years[i];
//
//       List<int> tmp_month = List.generate(12, (index) => index + 1);
//       if (end.year == year) {
//         tmp_month = List.generate(end.month, (index) => index + 1);
//       } else if (start.year == year) {
//         tmp_month = List.generate(12 - start.month + 1, (index) => index + start.month);
//       }
//       tmpMonths.add(tmp_month);
//       print('year $year month ${tmp_month}');
//
//       if (dType == DateType.YMD) {
//         List<List<int>> tmp_days = [];
//         for (int j = 0; j < tmp_month.length; j++) {
//           int month = tmp_month[j];
//           List<int> tmp_day;
//           if ([1, 3, 5, 7, 8, 10, 12].contains(month)) {
//             tmp_day = List.generate(31, (index) => index + 1);
//           } else if ([4, 6, 9, 11].contains(month)) {
//             tmp_day = List.generate(30, (index) => index + 1);
//           } else {
//             if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
//               tmp_day = List.generate(29, (index) => index + 1);
//             } else {
//               tmp_day = List.generate(28, (index) => index + 1);
//             }
//           }
//           if (end.year == year && end.month == month) {
//             tmp_day = List.generate(end.day, (index) => index + 1);
//           }
//           tmp_days.add(tmp_day);
//         }
//         tmpDays.add(tmp_days);
//       }
//     }
//     months = tmpMonths;
//     days = tmpDays;
//   }
// }
