import 'package:flutter/material.dart';

import 'state_view.dart';

typedef RefreshFunction = Future<void> Function(bool refresh);

/// 带下拉刷新的[ListView]
/// RefreshListView(
///   controller: _controller,
///   itemCount: articleList.length,
///   builder: (BuildContext context, int index) {
///     return _buildArticleItem(articleList[index], index);
///   },
///   refresh: _onRefresh,
///   showFooter: true,
/// )
class RefreshListView extends StatefulWidget {
  final StateController? controller; // 加载状态控制器
  final int itemCount; // item数量
  final IndexedWidgetBuilder builder; // 子item样式
  final RefreshFunction refresh; // refresh为true表示下拉刷新的回调, 为false表示上拉加载更多的回调
  final bool showFooter;

  const RefreshListView({
    super.key,
    required this.itemCount,
    required this.builder,
    required this.refresh,
    this.controller,
    this.showFooter = false,
  });

  @override
  State<StatefulWidget> createState() => _RefreshListViewState();
}

class _RefreshListViewState extends State<RefreshListView> {
  final ScrollController _controller = ScrollController(); // listView的控制器
  StateController? _stateController;

  @override
  void initState() {
    super.initState();

    _stateController = widget.controller ?? StateController();
    _controller.addListener(() {
      if (_controller.position.pixels == _controller.position.maxScrollExtent) {
        _loadingMore();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _stateController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 初始时，显示加载状态，如加载成功后隐藏页面并显示数据，之后显示加载更多

    // 根据列表数量判断是否初始化
    bool init = widget.itemCount != 0;
    // 列表数量
    int itemCount = widget.itemCount + (!widget.showFooter ? 0 : 1);

    return StateView(
      controller: _stateController!,
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
    return FooterStateView(controller: _stateController!, onTap: () => _loadingMore());
  }

  /// 第一次加载数据
  Future<void> _refresh({bool init = true}) async {
    if (!init) setState(() => _stateController!.loading());
    await widget.refresh(true);
  }

  /// 加载更多的数据
  Future<void> _loadingMore() async {
    setState(() => _stateController!.loading());
    await widget.refresh(false);
  }
}
