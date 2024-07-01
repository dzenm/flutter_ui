import 'dart:io';

import 'package:flutter/material.dart';

/// 统一滚动控件
class ScrollConfigurationWidget extends StatelessWidget {
  final Widget child;

  const ScrollConfigurationWidget(
    this.child, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollBehave(),
      child: Scrollbar(
        thickness: 5, //宽度
        radius: const Radius.circular(5), //圆角
        child: child,
      ),
    );
  }
}

//安卓系统去除滑动控件上下的蓝色水波纹
class ScrollBehave extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    if (Platform.isAndroid || Platform.isFuchsia) {
      return child;
    } else {
      return super.buildOverscrollIndicator(context, child, details);
    }
  }
}
