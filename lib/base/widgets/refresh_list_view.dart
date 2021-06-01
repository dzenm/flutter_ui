import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef RefreshFunction = Future<void> Function(bool refresh);

class RefreshListView extends StatefulWidget {
  final List list; // 数据
  final RefreshFunction refresh; // refresh为true表示下拉刷新的回调, 为false表示上拉加载更多的回调
  final IndexedWidgetBuilder builder; // 子item样式

  RefreshListView({
    required this.list,
    required this.refresh,
    required this.builder,
  });

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
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        itemBuilder: widget.builder,
        itemCount: widget.list.length + 1,
        controller: _controller,
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> _onRefresh() => widget.refresh(true);

  Future<void> _loadingMore() => widget.refresh(false);
}
