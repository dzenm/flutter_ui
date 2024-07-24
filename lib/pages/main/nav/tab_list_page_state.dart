import 'package:flutter/material.dart';

import '../../../base/base.dart';

abstract class TabListPageState<T extends StatefulWidget> extends State<T> {
  final StateController _controller = StateController();

  /// 加载的页数
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _getData(); // 第一次加载数据
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget buildContent(int len) {
    return RefreshListView(
      controller: _controller,
      itemCount: len,
      builder: (context, index) => buildItem(index),
      refresh: _onRefresh,
      padding: const EdgeInsets.all(16),
      showFooter: true,
    );
  }

  Widget buildItem(int index);

  /// [refresh]为true表示下拉刷新方法，为false表示上拉加载更多
  Future<void> _onRefresh(bool refresh) async {
    _pageIndex = (refresh ? 0 : _pageIndex);
    await _getData();
  }

  /// 加载数据，如果pageIndex为0表示从新加载
  Future<void> _getData() async {
    await getData(_pageIndex);
  }

  /// 加载数据
  Future<void> getData(int page);

  /// 更新加载成功的状态
  void updateState(int? pageCount) {
    if (!mounted) return;
    if (_pageIndex >= (pageCount ?? 0)) {
      _controller.loadEmpty(); // 加载完所有页面
    } else {
      // 加载数据成功，下次加载下一页
      ++_pageIndex;
      _controller.loadMore();
    }
    setState(() {});
  }

  /// 更新加载失败的状态
  void updateFailedState() {
    _controller.loadFailed();
    if (mounted) setState(() {});
  }
}
