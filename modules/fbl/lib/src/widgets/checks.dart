import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'tap.dart';

///
/// Created by a0010 on 2024/12/30 15:58
/// 具有开关/选择动作的通用组件
///

/// 有状态的单选组件
class SingleCheck extends StatefulWidget {
  final String text;
  final bool initialState;
  final void Function(bool isCheck) onChanged;
  final Color color;

  const SingleCheck({
    super.key,
    required this.text,
    this.initialState = false,
    required this.onChanged,
    this.color = Colors.blue,
  });

  @override
  State<SingleCheck> createState() => _SingleCheckState();
}

class _SingleCheckState extends State<SingleCheck> {
  bool _isCheck = false;

  @override
  void initState() {
    super.initState();
    _isCheck = widget.initialState;
  }

  @override
  Widget build(BuildContext context) {
    Color myColor = _isCheck //
        ? widget.color
        : Colors.grey;
    IconData icon = _isCheck //
        ? Icons.check_circle_rounded // 选中
        : Icons.radio_button_unchecked_rounded; // 未选中
    return TapLayout(
      onTap: () {
        _isCheck = !_isCheck;
        widget.onChanged(_isCheck);
        setState(() {});
      },
      foreground: Colors.transparent,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: myColor),
        const SizedBox(width: 8),
        Text(widget.text, style: const TextStyle(fontSize: 16)),
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
/// 单选组，配合 [_SingleCheck] 使用
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
          _SingleCheck(
            text: list[index],
            color: widget.color,
            isCheck: _selectedIndex == index,
            onChanged: () {
              _selectedIndex = index;
              if (widget.onChanged != null) widget.onChanged!(index);
              setState(() {});
            },
          ),
        ]),
      );
    }
    return widgets;
  }
}

/// 在一个单选组里选中一个选项
class SingleCheckGroup extends StatefulWidget {
  final List<String> titles;
  final int initialItem;
  final double spacer;
  final void Function(int index)? onChecked;

  const SingleCheckGroup({
    super.key,
    required this.titles,
    this.initialItem = 0,
    this.spacer = 32,
    this.onChecked,
  });

  @override
  State<SingleCheckGroup> createState() => _SingleCheckGroupState();
}

class _SingleCheckGroupState extends State<SingleCheckGroup> {
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialItem;
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: _buildRows());
  }

  List<Widget> _buildRows() {
    List<Widget> children = [];
    int len = widget.titles.length;
    for (int i = 0; i < len; i++) {
      String text = widget.titles[i];
      bool isCheck = _selected == i;
      children.add(
        _SingleCheck(
          text: text,
          isCheck: isCheck,
          onChanged: () {
            _selected = i;
            if (widget.onChecked != null) {
              widget.onChecked!(i);
            }
            setState(() {});
          },
        ),
      );
      if (i == len - 1) continue;
      children.add(SizedBox(width: widget.spacer));
    }
    return children;
  }
}

/// 无状态的单选组件
class _SingleCheck extends StatelessWidget {
  final String text;
  final bool isCheck;
  final void Function() onChanged;
  final Color color;

  const _SingleCheck({
    required this.text,
    this.isCheck = false,
    required this.onChanged,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    Color myColor = isCheck //
        ? color
        : Colors.grey;
    IconData icon = isCheck //
        ? Icons.check_circle_rounded // 选中
        : Icons.radio_button_unchecked_rounded; // 未选中
    return TapLayout(
      onTap: () {
        onChanged();
      },
      foreground: Colors.transparent,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: myColor),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16)),
      ]),
    );
  }
}

/// 开关组件
class SmallSwitch extends StatelessWidget {
  final bool value;
  final Function(bool)? onChanged;

  const SmallSwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // scale用来约束大小
    return Transform.scale(
      scale: 0.8,
      child: CupertinoSwitch(value: value, onChanged: onChanged, activeColor: Colors.blue),
    );
  }
}

/// 选择按钮组件
class RadioView extends StatelessWidget {
  final bool isSelect;

  const RadioView({super.key, this.isSelect = false});

  @override
  Widget build(BuildContext context) {
    IconData icon = isSelect //
        ? Icons.radio_button_checked
        : Icons.radio_button_unchecked;
    Color color = isSelect //
        ? Colors.blue
        : Colors.grey;
    return Icon(icon, color: color, size: 20);
  }
}
