import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/base/res/strings.dart';

import 'tap_layout.dart';

/// ListView加载底部数据的View
class StateView extends StatefulWidget {
  final LoadingState loadingState;
  final double? loadingProgressSize;
  final GestureTapCallback? onTap;
  final bool vertical;

  StateView({
    Key? key,
    this.loadingState = LoadingState.none,
    this.loadingProgressSize,
    this.vertical = true,
    this.onTap,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _StateViewState();
}

class _StateViewState extends State<StateView> {
  bool isTap = false;

  @override
  Widget build(BuildContext context) {
    double size = widget.loadingProgressSize ?? (widget.vertical ? 48 : 24);
    return Offstage(
      offstage: widget.loadingState == LoadingState.none,
      child: TapLayout(
        height: widget.vertical ? null : 56,
        onTap: widget.onTap,
        child: widget.vertical
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _stateView(size),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _stateView(size),
              ),
      ),
    );
  }

  List<Widget> _stateView(double size) {
    LoadingState state = widget.loadingState;
    return [
      Offstage(
        offstage: state != LoadingState.loading,
        child: Container(
          width: size,
          height: size,
          child: CircularProgressIndicator(),
        ),
      ),
      SizedBox(width: 16, height: 32),
      Text(loadingText(state)),
    ];
  }

  String loadingText(LoadingState state) {
    switch (state) {
      case LoadingState.none:
        return S.of.none;
      case LoadingState.loading:
        return S.of.loading;
      case LoadingState.empty:
        return S.of.loadEmpty;
      case LoadingState.more:
        return S.of.loadMore;
      case LoadingState.success:
        return S.of.loadSuccess;
      case LoadingState.failed:
        return S.of.loadFailed;
      case LoadingState.end:
        return S.of.loadEnd;
    }
  }
}

/// 加载数据的状态
enum LoadingState {
  none, // 什么都不做
  loading, // 加载中，正在请求数据
  empty, // 加载为空数据
  success, // 加载成功
  failed, // 加载错误
  more, // 底部显示，加载部分页数，还有更多页面可以加载
  end, // 底部显示，加载数据完成，没有数据可以加载
}
