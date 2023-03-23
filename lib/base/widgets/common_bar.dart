import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tap_layout.dart';

class CommonBar extends StatefulWidget {
  final Widget? title;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? statusBackgroundColor;
  final SystemUiOverlayStyle systemOverlayStyle;
  final Widget? suffix;

  const CommonBar({
    super.key,
    this.title,
    this.centerTitle = false,
    this.backgroundColor,
    this.statusBackgroundColor,
    this.systemOverlayStyle = SystemUiOverlayStyle.dark,
    this.suffix,
  });

  @override
  State<StatefulWidget> createState() => _CommonBarState();
}

class _CommonBarState extends State<CommonBar> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: widget.systemOverlayStyle,
        child: Material(
          color: widget.backgroundColor,
          child: Semantics(
            explicitChildNodes: true,
            child: Container(
              color: widget.backgroundColor,
              child: Column(children: [
                Container(height: 24, color: widget.statusBackgroundColor),
                Container(
                  height: kToolbarHeight,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      TapLayout(
                        isCircle: true,
                        width: 40,
                        height: 40,
                        onTap: () {
                          if (Navigator.canPop(context)) {
                            Navigator.pop(context);
                          }
                        },
                        child: BackButton(),
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: widget.centerTitle ? MainAxisAlignment.center : MainAxisAlignment.start,
                          children: [widget.title ?? Container()],
                        ),
                      ),
                      const SizedBox(width: 32),
                      widget.suffix ?? Container(),
                    ],
                  ),
                )
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
