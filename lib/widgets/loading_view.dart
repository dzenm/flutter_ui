import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// ListView加载底部数据的View
class LoadingFooterView extends StatefulWidget {
  final LoadingState loadingState;
  final double? loadingProgressSize;

  LoadingFooterView({
    this.loadingState = LoadingState.none,
    this.loadingProgressSize = 24,
  });

  @override
  State<StatefulWidget> createState() => _LoadingFooterViewState();
}

class _LoadingFooterViewState extends State<LoadingFooterView> {
  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: false,
      child: Container(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Offstage(
              offstage: widget.loadingState != LoadingState.loading,
              child: Container(
                width: widget.loadingProgressSize,
                height: widget.loadingProgressSize,
                child: CircularProgressIndicator(),
              ),
            ),
            SizedBox(width: 16),
            Text(loadingText(widget.loadingState)),
          ],
        ),
      ),
    );
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
  error, // 加载错误
  complete, // 加载数据完成，没有数据可以加载
}
