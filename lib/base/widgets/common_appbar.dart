import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tap_layout.dart';

/// appbar封装
class TopAppbar extends StatefulWidget implements PreferredSizeWidget {
  final bool back;
  final Color backgroundColor;
  final String? title;
  final String? subTitle;
  final double elevation;
  final Color titleColor;
  final Brightness brightness;
  final Widget? action;
  final Function? backFunc;
  final Widget? leadWidget;
  final bool centerTitle;
  final double titleSpacing;

  const TopAppbar(
    this.title, {super.key,
    this.back = true,
    this.titleColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.elevation = 0.5,
    this.centerTitle = true,
    this.brightness = Brightness.light,
    this.action,
    this.subTitle,
    this.backFunc,
    this.titleSpacing = NavigationToolbar.kMiddleSpacing,
    this.leadWidget,
  });

  @override
  Size get preferredSize => const Size.fromHeight(40); //appbar高度定制

  @override
  State<StatefulWidget> createState() => _TopAppbarState();
}

class _TopAppbarState extends State<TopAppbar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: widget.titleSpacing,
      leading: _leading(widget.titleColor, leadingWidget: widget.leadWidget, backFunc: widget.backFunc),
      backgroundColor: widget.backgroundColor,
      title: Text.rich(
        TextSpan(
          text: widget.title, // default text style
          children: [
            TextSpan(text: widget.subTitle ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
      ),
//      Text(widget.title),
      centerTitle: widget.centerTitle,
      elevation: widget.elevation,
      systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: widget.brightness),
      titleTextStyle: TextStyle(fontSize: 18.0, color: widget.titleColor, fontWeight: FontWeight.bold),
      actions: widget.action != null ? [widget.action!] : null,
    );
  }

  Widget? _leading(Color titleColor, {Widget? leadingWidget, Function? backFunc}) {
    return widget.back
        ? TapLayout(
            width: 40,
            height: 40,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 12),
            child: leadingWidget ?? Icon(Icons.chevron_left_rounded, size: 15, color: titleColor),
            onTap: () {
              if (backFunc == null) {
                _popThis(context);
              } else {
                backFunc();
              }
            },
          )
        : null;
  }

  void _popThis(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    }
  }
}
