import 'package:flutter/material.dart';

import 'popup_dialog.dart';

class PopupMenu extends StatelessWidget {
  final List<Widget> children;
  final Color? dividerColor;
  final double? dividerHeight;

  const PopupMenu({
    Key? key,
    this.children = const [],
    this.dividerColor = Colors.white,
    this.dividerHeight = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: children.length * 2 - 1,
      shrinkWrap: true,
      itemBuilder: (context, int i) {
        if (i.isOdd) {
          // 在每一列之前，添加一个分隔线widget
          return Divider(height: dividerHeight, color: dividerColor);
        }
        final int index = i ~/ 2;
        return children[index];
      },
      padding: const EdgeInsets.all(0.0),
    );
  }
}

class PopupItem extends StatefulWidget {
  final Widget? leading;
  final Widget child;
  final BoolCallback? onTap;
  final bool isTapClosePopup;
  final Color activeBackground;
  final Color background;

  const PopupItem({
    Key? key,
    this.leading,
    required this.child,
    this.onTap,
    this.background = Colors.white,
    this.activeBackground = const Color(0xFFd9d9d9),
    this.isTapClosePopup = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => PopupItemState();
}

class PopupItemState extends State<PopupItem> {
  bool isDown = false;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    if (widget.leading != null) {
      widgets.add(Container(
        padding: const EdgeInsets.all(8),
        width: 36.0,
        height: 36.0,
        child: IconTheme(data: const IconThemeData(color: Color(0xff007aff), size: 20.0), child: widget.leading!),
      ));
    }
    widgets.add(Expanded(child: DefaultTextStyle(style: const TextStyle(color: Color(0xff007aff)), child: widget.child)));
    return GestureDetector(
      onTapDown: (detail) {
        setState(() => isDown = true);
      },
      onTapUp: (detail) {
        if (isDown) {
          setState(() => isDown = false);
          if (widget.onTap != null && widget.onTap!()) {
            return;
          }
          if (widget.isTapClosePopup) {
            Navigator.of(context).pop();
          }
        }
      },
      onTapCancel: () {
        if (isDown) {
          setState(() => isDown = false);
        }
      },
      child: Container(
        color: isDown ? widget.activeBackground : widget.background,
        child: Padding(
          padding: const EdgeInsets.only(top: 2.5, bottom: 2.5),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: widgets),
        ),
      ),
    );
  }
}
