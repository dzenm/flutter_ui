import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'tap_layout.dart';

/// ListView加载底部数据的View
class LoadingView extends StatefulWidget {
  final LoadingState loadingState;
  final double? loadingProgressSize;
  final GestureTapCallback? onTap;
  final bool vertical;

  LoadingView({
    Key? key,
    this.loadingState = LoadingState.none,
    this.loadingProgressSize,
    this.vertical = true,
    this.onTap,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
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
                children: _loadingView(size),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _loadingView(size),
              ),
      ),
    );
  }

  List<Widget> _loadingView(double size) {
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
        return '';
      case LoadingState.loading:
        return '正在加载中...';
      case LoadingState.empty:
        return '加载为空';
      case LoadingState.more:
        return '加载更多';
      case LoadingState.success:
        return '加载成功';
      case LoadingState.error:
        return '加载失败';
      case LoadingState.end:
        return '滑动到最底部了';
    }
  }
}

/// 加载数据的状态
enum LoadingState {
  none, // 什么都不做
  loading, // 加载中，正在请求数据
  empty, // 加载为空数据
  success, // 加载成功
  error, // 加载错误
  more, // 底部显示，加载部分页数，还有更多页面可以加载
  end, // 底部显示，加载数据完成，没有数据可以加载
}
