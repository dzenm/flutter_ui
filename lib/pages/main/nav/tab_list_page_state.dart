
import 'package:flutter/material.dart';

import '../../../base/widgets/refresh_list_view.dart';
import '../../../base/widgets/state_view.dart';

abstract class TabListPageState<T extends StatefulWidget> extends State<T> {
  final StateController _controller = StateController();
  int _page = 0; // 加载的页数

  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
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

  Future<void> _onRefresh(bool refresh) async => await _getData(isReset: refresh);

  Future<void> _getData({bool isReset = false}) async {
    _page = isReset ? 0 : _page;
    getData(_page);
  }

  Future<void> getData(int page);

  void updateState(int? pageCount) {
    _controller.loadComplete(); // 加载成功
    if (_page >= (pageCount ?? 0)) {
      _controller.loadEmpty(); // 加载完所有页面
    } else {
      // 加载数据成功，下次加载下一页
      ++_page;
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
