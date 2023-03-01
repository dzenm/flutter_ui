import 'package:flutter/material.dart';

import 'state_view.dart';

typedef RefreshFunction = Future<void> Function(bool refresh);

class RefreshListView extends StatefulWidget {
  final StateController controller; // 加载状态控制器
  final int itemCount; // item数量
  final IndexedWidgetBuilder builder; // 子item样式
  final RefreshFunction refresh; // refresh为true表示下拉刷新的回调, 为false表示上拉加载更多的回调
  final bool showFooter;

  RefreshListView({
    Key? key,
    required this.controller,
    required this.itemCount,
    required this.builder,
    required this.refresh,
    this.showFooter = false,
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

    // 根据列表数量判断是否初始化
    bool init = widget.itemCount != 0;
    // 列表数量
    int itemCount = widget.itemCount + (!widget.showFooter ? 0 : 1);

    return StateView(
      controller: widget.controller,
      onTap: () => _refresh(init: init),
      child: !init
          ? null
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                itemBuilder: _buildItem,
                itemCount: itemCount,
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
  Future<void> _refresh({bool init = true}) async {
    if (!init) setState(() => widget.controller.loading());
    await widget.refresh(true);
  }

  /// 加载更多的数据
  Future<void> _loadingMore() async {
    setState(() => widget.controller.loading());
    await widget.refresh(false);
  }
}
