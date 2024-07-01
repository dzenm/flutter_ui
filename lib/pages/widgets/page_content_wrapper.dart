import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/12/11 09:55
///
class PageContentWrapper extends StatelessWidget {
  final Widget child;
  final Color color;

  const PageContentWrapper({super.key, required this.child, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: child,
    );
  }
}
