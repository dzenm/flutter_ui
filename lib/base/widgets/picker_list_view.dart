///
/// Created by a0010 on 2022/8/29 11:21
///
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../res/strings.dart';

typedef OnSelectedChanged = void Function(int index);

class PickerListView extends StatefulWidget {
  /// 选中的地址发生改变回调
  final int itemCount;
  final IndexedWidgetBuilder builder;
  final OnSelectedChanged? onSelectedChanged;
  final int defaultIndex;

  PickerListView({
    Key? key,
    this.itemCount = 0,
    required this.builder,
    this.onSelectedChanged,
    this.defaultIndex = 0,
  }) : super(key: key);

  static Future<T?> show<T>({
    required BuildContext context,
    int itemCount = 0,
    required IndexedWidgetBuilder builder,
    OnSelectedChanged? onSelectedChanged,
    int defaultIndex = 0,
  }) async {
    return await showModalBottomSheet<T>(
      context: context,
      enableDrag: true,
      builder: (context) => BottomSheet(
        onClosing: () {},
        builder: (context) => Container(
          child: PickerListView(
            itemCount: itemCount,
            builder: builder,
            onSelectedChanged: onSelectedChanged,
            defaultIndex: defaultIndex,
          ),
        ),
      ),
    );
  }

  /// PickerListView.showList(
  ///   context: context,
  ///   list: ['测试一', '测试二', '测试三', '测试四', '测试五'],
  ///   defaultIndex: _selectedIndex,
  ///   onSelectedChanged: (index) {
  ///     _selectedIndex = index;
  ///     Log.i('选中的回调: $_selectedIndex');
  ///   },
  /// )
  ///
  static Future<T?> showList<T>({
    required BuildContext context,
    required List<String> list,
    OnSelectedChanged? onSelectedChanged,
    int defaultIndex = 0,
  }) async {
    Widget _buildItem(BuildContext context, int index) {
      String item = list[index];
      if (item.isEmpty) {
        return Container();
      }
      return Container(
        alignment: Alignment.center,
        child: Text(item, style: const TextStyle(color: Colors.black, fontSize: 17)),
      );
    }

    return await show<T>(
      context: context,
      itemCount: list.length,
      builder: _buildItem,
      onSelectedChanged: onSelectedChanged,
      defaultIndex: defaultIndex,
    );
  }

  _PickerListViewState createState() => _PickerListViewState();
}

class _PickerListViewState extends State<PickerListView> {
  FixedExtentScrollController? _controller;

  final double _kPickerHeight = 220.0;
  final double _kPickerTitleHeight = 44.0;

  int _selectedIndex = 0;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    _selectedIndex = widget.defaultIndex;
    _controller = FixedExtentScrollController(initialItem: _selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _kPickerHeight,
      color: Colors.white,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _buildButtonView(),
        Flexible(child: _buildListView()),
      ]),
    );
  }

  Widget _buildButtonView() {
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          height: _kPickerTitleHeight,
          child: TextButton(
            child: Text(
              S.of(context).cancel,
              style: TextStyle(color: Theme.of(context).unselectedWidgetColor, fontSize: 16.0),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Container(
          height: _kPickerTitleHeight,
          child: TextButton(
            child: Text(
              S.of(context).confirm,
              style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 16.0),
            ),
            onPressed: () {
              if (widget.onSelectedChanged != null) {
                widget.onSelectedChanged!(_selectedIndex);
              }
              Navigator.pop(context);
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildListView() {
    return CupertinoPicker.builder(
      backgroundColor: Colors.white,
      childCount: widget.itemCount,
      scrollController: _controller,
      itemBuilder: widget.builder,
      itemExtent: 44,
      onSelectedItemChanged: (int index) {
        setState(() => _selectedIndex = index);
      },
    );
  }
}
