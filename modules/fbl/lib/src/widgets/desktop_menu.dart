import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/9/27 14:49
///
class DesktopMenu extends StatelessWidget {
  final Widget child;
  final Widget secondaryChild;
  final double width;

  const DesktopMenu({
    super.key,
    required this.child,
    required this.secondaryChild,
    this.width = 240,
  });

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildPrimaryMenu(),
      const VerticalDivider(thickness: 1, width: 1),
      Expanded(child: _buildSecondaryMenu()),
    ]);
  }

  Widget _buildPrimaryMenu() {
    return SizedBox(
      width: width,
      child: child,
    );
  }

  Widget _buildSecondaryMenu() {
    return Container(
      child: secondaryChild,
    );
  }
}
