import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/2/10 13:33
/// 缓存PageView的子页面，使其不被销毁
class KeepAliveWrapper extends StatefulWidget {
  final bool keepAlive;
  final Widget child;

  const KeepAliveWrapper({
    super.key,
    this.keepAlive = true,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  void didUpdateWidget(KeepAliveWrapper oldWidget) {
    // 状态发生变化时调用
    if (oldWidget.keepAlive != widget.keepAlive) {
      // 更新KeepAlive状态
      updateKeepAlive();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}
