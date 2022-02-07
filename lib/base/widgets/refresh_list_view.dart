import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'state_view.dart';

typedef RefreshFunction = Future<void> Function(bool refresh);

class RefreshListView extends StatefulWidget {
  final StateController controller; // 加载状态控制器
  final int itemCount; // item数量
  final IndexedWidgetBuilder builder; // 子item样式
  final RefreshFunction refresh; // refresh为true表示下拉刷新的回调, 为false表示上拉加载更多的回调

  RefreshListView({
    Key? key,
    required this.controller,
    required this.itemCount,
    required this.builder,
    required this.refresh,
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
      controller: widget.controller,
      onTap: () => _refresh(),
      child: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          itemBuilder: _buildItem,
          itemCount: widget.controller.state == LoadState.none ? widget.itemCount : widget.itemCount + 1,
          controller: _controller,
        ),
      ),
    );
  }

  /// 渲染列表的item, 处理底部加载更多的情况
  Widget _buildItem(BuildContext context, int index) {
    if (index < widget.itemCount) {
      return widget.builder(context, index);
    }
    return FooterStateView(controller: widget.controller, onTap: () => _loadingMore());
  }

  /// 第一次加载数据
  Future<void> _refresh() async {
    widget.refresh(true);
  }

  /// 加载更多的数据
  Future<void> _loadingMore() async {
    setState(() => widget.controller.loading());
    widget.refresh(false);
  }
}
