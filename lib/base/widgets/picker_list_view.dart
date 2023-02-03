///
/// Created by a0010 on 2022/8/29 11:21
///
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../log/log.dart';
import '../res/strings.dart';

typedef SelectedChanged = void Function(String item);

const double _kPickerHeight = 220.0;
const double _kPickerTitleHeight = 44.0;

void showListDialog({
  required BuildContext context,
  required List<String> data,
  required String? selectedItem,
  required SelectedChanged? onSelectedChanged,
}) {
  showModalBottomSheet(
    context: context,
    enableDrag: true,
    builder: (context) => BottomSheet(
      onClosing: () {},
      builder: (context) => Container(
        height: _kPickerHeight,
        child: PickerListView(
          selectedItem: selectedItem,
          data: data,
          onSelectedChanged: onSelectedChanged,
        ),
      ),
    ),
  );
}

class PickerListView extends StatefulWidget {
  final List<String>? data;

  /// 选中的地址发生改变回调
  final SelectedChanged? onSelectedChanged;

  final String? selectedItem;

  PickerListView({
    Key? key,
    this.data,
    this.onSelectedChanged,
    this.selectedItem,
  }) : super(key: key);

  _PickerListViewState createState() => _PickerListViewState();
}

class _PickerListViewState extends State<PickerListView> {
  List<String> list = [];
  int _selectedIndex = 0;

  FixedExtentScrollController? _controller;

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
    list = widget.data ?? [];
    if (list.isNotEmpty) {
      _selectedIndex = list.indexOf(widget.selectedItem ?? '');
      Log.d('初始化选中: ${widget.selectedItem}');
    }
    _controller = FixedExtentScrollController(initialItem: _selectedIndex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (list.isEmpty) {
      return Container();
    }

    return Container(
      height: _kPickerHeight,
      color: Colors.white,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Flexible(child: _buildButtonView()),
        Flexible(child: _buildListView()),
      ]),
    );
  }

  Widget _buildButtonView() {
    return Container(
      height: _kPickerTitleHeight,
      decoration: BoxDecoration(color: Colors.white),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          height: _kPickerTitleHeight,
          child: TextButton(
            child: Text(
              S.of(context).cancel,
              style: TextStyle(color: Theme.of(context).unselectedWidgetColor, fontSize: 16.0),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
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
              if (widget.onSelectedChanged != null && list.isNotEmpty && _selectedIndex != -1) {
                widget.onSelectedChanged!(list[_selectedIndex]);
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
      childCount: list.length,
      scrollController: _controller,
      itemBuilder: (context, index) {
        String item = list[index];
        if (item.isEmpty) {
          return Container();
        }
        return Container(
          alignment: Alignment.center,
          child: Text(item, style: const TextStyle(color: Colors.black, fontSize: 17)),
        );
      },
      itemExtent: 44,
      onSelectedItemChanged: (int index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    );
  }
}
