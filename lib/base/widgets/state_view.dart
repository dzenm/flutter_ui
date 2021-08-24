import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/base/res/strings.dart';

import 'tap_layout.dart';

/// 状态展示
class StateView extends StatefulWidget {
  final Widget? child;
  final LoadState state;
  final GestureTapCallback? onTap;
  final Widget? title;
  final Widget? image;

  StateView({
    Key? key,
    this.child,
    this.state = LoadState.none,
    this.onTap,
    this.title,
    this.image,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StateViewState();
}

class _StateViewState extends State<StateView> {
  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: widget.state == LoadState.none,
      child: widget.state == LoadState.success
          ? widget.child
          : TapLayout(
              height: 56,
              onTap: widget.onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _stateView(56),
              ),
            ),
    );
  }

  List<Widget> _stateView(double size) {
    LoadState state = widget.state;
    return [
      Offstage(
        offstage: state != LoadState.loading,
        child: Container(
          width: size,
          height: size,
          child: CircularProgressIndicator(),
        ),
      ),
      Offstage(
        offstage: state != LoadState.empty || state != LoadState.failed,
        child: widget.image,
      ),
      SizedBox(width: 16, height: 32),
      widget.title == null ? Text(stateText(state)) : widget.title!,
    ];
  }

  String stateText(LoadState state) {
    switch (state) {
      case LoadState.none:
        return S.of.none;
      case LoadState.loading:
        return S.of.loading;
      case LoadState.empty:
        return S.of.loadEmpty;
      case LoadState.success:
        return S.of.loadSuccess;
      case LoadState.failed:
        return S.of.loadFailed;
    }
  }
}

/// 加载数据的状态
enum LoadState {
  none, // 什么都不做
  loading, // 加载中，正在请求数据
  empty, // 加载为空数据
  success, // 加载成功
  failed, // 加载错误
}
