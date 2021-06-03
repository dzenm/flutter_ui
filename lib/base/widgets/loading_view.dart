import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';

/// ListView加载底部数据的View
class LoadingView extends StatefulWidget {
  final LoadingState loadingState;
  final double? loadingProgressSize;
  final GestureTapCallback? onTap;
  final bool vertical;

  LoadingView({
    this.loadingState = LoadingState.none,
    this.loadingProgressSize,
    this.vertical = true,
    this.onTap,
  });

  @override
  State<StatefulWidget> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
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
    return [
      Offstage(
        offstage: widget.loadingState != LoadingState.loading,
        child: Container(
          width: size,
          height: size,
          child: CircularProgressIndicator(),
        ),
      ),
      SizedBox(width: 16, height: 32),
      Text(loadingText(widget.loadingState)),
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
      case LoadingState.complete:
        return '滑动到最底部了';
    }
  }
}

/// 加载数据的状态
enum LoadingState {
  none, // 什么都不做
  loading, // 加载中，正在请求数据
  empty, // 加载为空数据
  more, // 加载部分页数，还有更多页面可以加载
  success, // 加载成功
  error, // 加载错误
  complete, // 加载数据完成，没有数据可以加载
}
