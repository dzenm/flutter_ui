import 'package:flutter/material.dart';

import '../../res/custom_icon.dart';
import 'tap_layout.dart';

class CommonBar extends StatefulWidget {
  final Widget? title;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? statusBackgroundColor;
  final Brightness brightness;
  final Widget? suffix;

  const CommonBar({
    super.key,
    this.title,
    this.centerTitle = false,
    this.backgroundColor,
    this.statusBackgroundColor,
    this.brightness = Brightness.light,
    this.suffix,
  });

  @override
  State<StatefulWidget> createState() => _CommonBarState();
}

class _CommonBarState extends State<CommonBar> {
  @override
  Widget build(BuildContext context) {
    Color color = widget.brightness == Brightness.light ? Colors.white : Colors.black87;
    return Container(
      color: widget.backgroundColor,
      child: Column(children: [
        Container(height: 24, color: widget.statusBackgroundColor),
        Container(
          height: kToolbarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: widget.centerTitle ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              TapLayout(
                isCircle: true,
                width: 48,
                height: 48,
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: Icon(CustomIcon.left_big, color: color),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 1,
                child: Row(children: [widget.title ?? Container()]),
              ),
              const SizedBox(width: 32),
              widget.suffix ?? Container(),
            ],
          ),
        )
      ]),
    );
  }
}
