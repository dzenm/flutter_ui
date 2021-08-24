import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'footer_state.dart';
import 'state_view.dart';

typedef RefreshFunction = Future<void> Function(bool refresh);

class RefreshListView extends StatefulWidget {
  final LoadState loadState; // 加载状态
  final FooterState footerState; // 加载状态
  final int itemCount; // item数量
  final IndexedWidgetBuilder builder; // 子item样式
  final RefreshFunction refresh; // refresh为true表示下拉刷新的回调, 为false表示上拉加载更多的回调
  final bool isShowFooterLoading;

  RefreshListView({
    Key? key,
    this.loadState = LoadState.none,
    this.footerState = FooterState.none,
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
    return StateView(
      state: widget.loadState,
      onTap: () => _onRefresh(),
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          itemBuilder: _renderItem,
          itemCount: widget.isShowFooterLoading ? widget.itemCount + 1 : widget.itemCount,
          controller: _controller,
        ),
      ),
    );
  }

  /// 渲染列表的item, 处理底部加载更多的情况
  Widget _renderItem(BuildContext context, int index) {
    if (index < widget.itemCount) {
      return widget.builder(context, index);
    }
    return FooterView(state: widget.footerState, onTap: () => _loadingMore());
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
