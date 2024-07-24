import 'package:flutter/material.dart';

import 'package:fbl/fbl.dart';

///
/// Created by a0010 on 2023/12/12 10:53
///
class SingleItemView extends StatelessWidget {
  final String title;
  final GestureTapCallback? onTap;
  final Widget? suffix;
  final EdgeInsetsGeometry? margin;
  final bool isShowForward;
  final Color? titleColor;

  const SingleItemView({
    super.key,
    required this.title,
    this.onTap,
    this.suffix,
    this.margin,
    this.isShowForward = true,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return TapLayout(
      onTap: onTap,
      background: Colors.white,
      margin: margin,
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleTextView(
        title: title,
        suffix: suffix,
        titleColor: titleColor,
        isShowForward: isShowForward,
        forwardColor: Colors.grey,
      ),
    );
  }
}
