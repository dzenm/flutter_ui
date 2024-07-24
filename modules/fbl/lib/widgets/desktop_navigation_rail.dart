import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/12/27 16:15
///
class DesktopNavigationRail extends StatefulWidget {
  final double width;
  final Widget? leading;
  final Widget? trailing;
  final Color? backgroundColor;
  final double verticalPadding;
  final List<Widget> children;
  final ValueChanged<int>? onSelected;

  const DesktopNavigationRail({
    super.key,
    this.width = 48,
    this.leading,
    this.trailing,
    this.backgroundColor,
    this.verticalPadding = 32,
    required this.children,
    this.onSelected,
  });

  @override
  State<DesktopNavigationRail> createState() => _DesktopNavigationRailState();
}

class _DesktopNavigationRailState extends State<DesktopNavigationRail> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      child: Material(
        color: widget.backgroundColor,
        child: SafeArea(
          child: SizedBox(
            width: widget.width,
            child: Column(children: [
              _verticalSpacer,
              if (widget.leading != null) ...[
                widget.leading!,
                _verticalSpacer,
                _verticalSpacer,
              ],
              for (var i = 0; i < widget.children.length; i++) ...[
                GestureDetector(
                  onTap: () {
                    if (widget.onSelected != null) {
                      widget.onSelected!(i);
                    }
                  },
                  child: widget.children[i],
                ),
                SizedBox(height: widget.verticalPadding),
              ],
              if (widget.trailing != null) ...[
                _verticalSpacer,
                _verticalSpacer,
                widget.trailing!,
              ],
              _verticalSpacer,
            ]),
          ),
        ),
      ),
    );
  }
}

const Widget _verticalSpacer = SizedBox(height: 8.0);

