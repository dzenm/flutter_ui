import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'loading_view.dart';

typedef RefreshFunction = Future<void> Function(bool refresh);

class RefreshListView extends StatefulWidget {
  final bool isInit;
  final LoadingState loadingState; // 加载状态
  final int itemCount; // item数量
  final IndexedWidgetBuilder builder; // 子item样式
  final RefreshFunction refresh; // refresh为true表示下拉刷新的回调, 为false表示上拉加载更多的回调
  final bool isShowFooterLoading;

  RefreshListView({
    Key? key,
    this.isInit = false,
    this.loadingState = LoadingState.none,
    required this.itemCount,
    required this.builder,
    required this.refresh,
    this.isShowFooterLoading = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RefreshListViewState();
}

class _RefreshListViewState extends State<RefreshListView> {
  ScrollController _controller = ScrollController(); // listView的控制器

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        _loadingMore();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 初始时，显示加载状态，如加载成功后隐藏页面并显示数据，之后显示加载更多
    return widget.isInit
        ? RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              itemBuilder: _renderItem,
              itemCount: widget.isShowFooterLoading ? widget.itemCount + 1 : widget.itemCount,
              controller: _controller,
            ),
          )
        : LoadingView(
            loadingState: widget.loadingState,
            onTap: () => _onRefresh(),
          );
  }

  /// 渲染列表的item, 处理底部加载更多的情况
  Widget _renderItem(BuildContext context, int index) {
    if (index < widget.itemCount) {
      return widget.builder(context, index);
    }
    return LoadingView(loadingState: widget.loadingState, vertical: false, onTap: () => _loadingMore());
  }

  /// 第一次加载数据
  Future<void> _onRefresh() async {
    widget.refresh(true);
  }

  /// 加载更多的数据
  Future<void> _loadingMore() async {
    widget.refresh(false);
  }
}
