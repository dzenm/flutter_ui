import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tap_layout.dart';

/// AppBar封装
class CommonBar extends StatefulWidget {
  final String? title;
  final Color? titleColor;
  final bool? centerTitle;
  final String? subTitle;
  final Color? subTitleColor;
  final Color? backgroundColor;
  final bool showLeading;
  final Widget? leading;
  final Function? onBackTap;
  final double? elevation;
  final double toolbarHeight;
  final SystemUiOverlayStyle systemUiOverlayStyle;
  final List<Widget>? actions;
  final double? titleSpacing;

  const CommonBar({
    super.key,
    this.title,
    this.titleColor = Colors.white,
    this.centerTitle = true,
    this.subTitle,
    this.subTitleColor,
    this.backgroundColor,
    this.showLeading = true,
    this.leading,
    this.onBackTap,
    this.elevation = 0.0,
    this.toolbarHeight = kToolbarHeight,
    this.systemUiOverlayStyle = SystemUiOverlayStyle.light,
    this.actions,
    this.titleSpacing = NavigationToolbar.kMiddleSpacing,
  });

  @override
  State<StatefulWidget> createState() => _CommonBarState();
}

class _CommonBarState extends State<CommonBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: widget.titleSpacing,
      leading: _buildLeading(
        widget.titleColor,
        leading: widget.leading,
        onBackTap: widget.onBackTap,
      ),
      backgroundColor: widget.backgroundColor,
      foregroundColor: widget.titleColor,
      title: Text.rich(
        TextSpan(
          text: widget.title,
          children: [
            TextSpan(
              text: widget.subTitle ?? '',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      titleTextStyle: TextStyle(fontSize: 18.0, color: widget.titleColor, fontWeight: FontWeight.bold),
      centerTitle: widget.centerTitle,
      elevation: widget.elevation,
      toolbarHeight: widget.toolbarHeight,
      systemOverlayStyle: widget.systemUiOverlayStyle,
      actions: widget.actions,
    );
  }

  Widget? _buildLeading(Color? titleColor, {Widget? leading, Function? onBackTap}) {
    if (widget.showLeading) return null;
    return TapLayout(
      width: 40,
      height: 40,
      isCircle: true,
      padding: const EdgeInsets.only(left: 12),
      child: leading ?? BackButtonIcon(),
      onTap: () {
        if (onBackTap == null) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        } else {
          onBackTap();
        }
      },
    );
  }

  Widget _buildToolbar() {
    return Semantics(
      container: true,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: widget.systemUiOverlayStyle,
        child: Material(
          color: widget.backgroundColor,
          child: Semantics(
            explicitChildNodes: true,
            child: Container(
              color: widget.backgroundColor,
              child: Column(children: [
                Container(height: 24, color: widget.backgroundColor),
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
                        child: Row(mainAxisAlignment: widget.centerTitle ?? false ? MainAxisAlignment.center : MainAxisAlignment.start, children: [
                          Text.rich(
                            TextSpan(text: widget.title, children: [
                              TextSpan(
                                text: widget.subTitle ?? '',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                              ),
                            ]),
                          ),
                        ]),
                      ),
                      const SizedBox(width: 32),
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
