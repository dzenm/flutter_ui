import 'package:flutter/material.dart';

import 'tap_layout.dart';

///
/// Created by a0010 on 2023/5/17 15:20
/// 单选框组件
class CheckBox extends StatefulWidget {
  final String text;
  final Color color;
  final Color selectColor;
  final Color unselectColor;
  final ValueChanged<bool>? onChanged;

  const CheckBox({
    super.key,
    required this.text,
    this.color = Colors.grey,
    this.selectColor = Colors.blue,
    this.unselectColor = Colors.grey,
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
    IconData icon = _isSelected
        ? Icons.check_circle_rounded // 选中
        : Icons.radio_button_unchecked_rounded; // 未选中
    Color iconColor = _isSelected ? widget.selectColor : widget.unselectColor;
    return TapLayout(
      foreground: Colors.transparent,
      onTap: () {
        _isSelected = !_isSelected;
        if (widget.onChanged != null) widget.onChanged!(_isSelected);
        setState(() {});
      },
      child: Row(children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 10),
        Text(widget.text, style: TextStyle(fontSize: 14, color: widget.color)),
      ]),
    );
  }
}

///
/// CheckGroup(
///   list: ['左上', '正左', '左下', '上左', '正上', '上右', '右上', '正右', '右下', '下右', '正下', '下左'],
///   padding: EdgeInsets.symmetric(vertical: 16),
///   childAspectRatio: 2.2,
///   crossAxisCount: 3,
///   crossAxisSpacing: 2,
///   onChanged: (index) {
///     PopupDirection.values.forEach((direct) {
///       if (direct.index == index) {
///         _direction = direct;
///       }
///     });
///   },
/// )
/// 单选组，配合 [CheckItem] 使用
class CheckGroup extends StatefulWidget {
  final List<String> list;
  final int initialValue;
  final Color color;
  final Color selectColor;
  final Color unselectColor;
  final double childAspectRatio;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<int>? onChanged;

  const CheckGroup({
    super.key,
    required this.list,
    this.initialValue = 0,
    this.color = Colors.grey,
    this.selectColor = Colors.blue,
    this.unselectColor = Colors.grey,
    this.childAspectRatio = 1,
    this.crossAxisCount = 1,
    this.crossAxisSpacing = 0.0,
    this.mainAxisSpacing = 0.0,
    this.padding,
    this.onChanged,
  });

  @override
  State<StatefulWidget> createState() => _CheckGroupState();
}

class _CheckGroupState extends State<CheckGroup> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      // 宽/高比
      childAspectRatio: widget.childAspectRatio,
      //设置一行的个数
      crossAxisCount: widget.crossAxisCount,
      //设置列间距
      crossAxisSpacing: widget.crossAxisSpacing,
      //设置行间距
      mainAxisSpacing: widget.mainAxisSpacing,
      children: _buildItems(),
    );
  }

  List<Widget> _buildItems() {
    List<Widget> widgets = [];
    List<String> list = widget.list;
    for (int index = 0; index < list.length; index++) {
      widgets.add(
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          CheckItem(
            text: list[index],
            index: index,
            selectedIndex: _selectedIndex,
            color: widget.color,
            selectColor: widget.selectColor,
            unselectColor: widget.unselectColor,
            padding: widget.padding,
            onChanged: (value) {
              _selectedIndex = value;
              if (widget.onChanged != null) widget.onChanged!(value);
              setState(() {});
            },
          ),
        ]),
      );
    }
    return widgets;
  }
}

/// 单选Item组件
class CheckItem extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final String text;
  final Color color;
  final Color selectColor;
  final Color unselectColor;
  final EdgeInsetsGeometry? padding;
  final ValueChanged<int>? onChanged;

  const CheckItem({
    super.key,
    required this.index,
    required this.selectedIndex,
    required this.text,
    this.color = Colors.grey,
    this.selectColor = Colors.blue,
    this.unselectColor = Colors.grey,
    this.padding,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = selectedIndex == index;
    IconData icon = isSelected
        ? Icons.check_circle_rounded // 选中
        : Icons.radio_button_unchecked_rounded; // 未选中
    Color iconColor = isSelected ? selectColor : unselectColor;
    return TapLayout(
      foreground: Colors.transparent,
      onTap: () {
        if (onChanged != null) onChanged!(index);
      },
      padding: padding,
      child: Row(children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 10),
        Text(text, style: TextStyle(fontSize: 14, color: color)),
      ]),
    );
  }
}
