import 'package:flutter/material.dart';

import 'tap_layout.dart';

///
/// Created by a0010 on 2023/5/17 15:20
/// 单选框组件
class CheckBox extends StatefulWidget {
  final String text;
  final Color? color;
  final Color? selectColor;
  final Color? unselectColor;
  final ValueChanged<bool>? onChanged;

  const CheckBox({
    required this.text,
    this.color,
    this.selectColor,
    this.unselectColor,
    this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => _CheckBoxState();
}

class _CheckBoxState extends State<CheckBox> {
  /// 是否选中
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return TapLayout(
      foreground: Colors.transparent,
      onTap: () {
        _isSelected = !_isSelected;
        setState(() {});
        if (widget.onChanged != null) widget.onChanged!(_isSelected);
      },
      child: Row(children: [
        Icon(
          _isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 16,
          color: _isSelected ? widget.selectColor ?? Colors.blue : widget.unselectColor ?? Colors.grey,
        ),
        SizedBox(width: 10),
        Text(widget.text, style: TextStyle(fontSize: 14, color: widget.color ?? Colors.grey))
      ]),
    );
  }
}

/// CheckGroup(
///   list: ['左上', '正左', '左下'],
///   padding: EdgeInsets.symmetric(vertical: 16),
///   onChanged: (index) {
///   },
/// ),
/// 单选组，配合 [CheckItem] 使用
class CheckGroup extends StatefulWidget {
  final bool isVertical;
  final List<String> list;
  final Color? color;
  final Color? selectColor;
  final Color? unselectColor;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<int>? onChanged;

  CheckGroup({
    required this.list,
    this.isVertical = false,
    this.color,
    this.selectColor,
    this.unselectColor,
    this.padding,
    this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => _CheckGroupState();
}

class _CheckGroupState extends State<CheckGroup> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _buildItems(),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _buildItems(),
    );
  }

  List<Widget> _buildItems() {
    List<Widget> widgets = [];
    List<String> list = widget.list;
    for (int index = 0; index < list.length; index++) {
      widgets.add(CheckItem(
        text: list[index],
        index: index,
        selectedIndex: _selectedIndex,
        color: widget.color,
        selectColor: widget.selectColor,
        unselectColor: widget.unselectColor,
        padding: widget.padding,
        onChanged: (value) {
          _selectedIndex = value;
          setState(() {});
        },
      ));
    }
    return widgets;
  }
}

/// 单选Item组件
class CheckItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final String text;
  final Color? color;
  final Color? selectColor;
  final Color? unselectColor;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<int>? onChanged;

  CheckItem({
    required this.index,
    required this.selectedIndex,
    required this.text,
    this.color,
    this.selectColor,
    this.unselectColor,
    this.padding,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedIndex == index;
    return TapLayout(
      foreground: Colors.transparent,
      onTap: () {
        if (onChanged != null) onChanged!(index);
      },
      padding: padding,
      child: Row(children: [
        Icon(
          isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 16,
          color: isSelected ? selectColor ?? Colors.blue : unselectColor ?? Colors.grey,
        ),
        SizedBox(width: 10),
        Text(text, style: TextStyle(fontSize: 14, color: color ?? Colors.grey))
      ]),
    );
  }
}
