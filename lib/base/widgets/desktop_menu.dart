import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/9/27 14:49
///
class DesktopMenu extends StatefulWidget {
  final Widget child;
  final Widget secondaryChild;

  const DesktopMenu({
    super.key,
    required this.child,
    required this.secondaryChild,
  });

  @override
  State<DesktopMenu> createState() => _DesktopMenuState();
}

class _DesktopMenuState extends State<DesktopMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _buildPrimaryMenu(),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: _buildSecondaryMenu()),
      ]),
    );
  }

  Widget _buildPrimaryMenu() {
    return Container(
      width: 150,
      child: widget.child,
    );
  }

  Widget _buildSecondaryMenu() {
    return Container(
      child: widget.secondaryChild,
    );
  }
}
