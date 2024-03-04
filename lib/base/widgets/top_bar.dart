import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/12/18 11:20
///
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Color backgroundColor;
  final List<Widget>? actions;
  final double height;

  const TopBar({
    super.key,
    this.title,
    this.backgroundColor = Colors.white,
    this.actions,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      title: title,
      backgroundColor: backgroundColor,
      leading: null,
      centerTitle: false,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
