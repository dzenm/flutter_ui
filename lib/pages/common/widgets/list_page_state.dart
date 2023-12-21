import 'package:flutter/material.dart';

import '../../../base/base.dart';

///
/// Created by a0010 on 2023/2/23 13:35
/// 列表页面State
/// 页面UI只有一个带 [RefreshIndicator] 的 [ListView] ，请求数据实现 [ListPageState.getData] ，
/// 创建 [ListView] Item实现 [ListPageState.buildItem]，修改 [CommonBar] 实现 [ListPageState.buildAppbar]
///
/// 创建自己的 [State] 直接继承 [ListPageState]，[D] 为列表的数据结构类型，[T] 为StateWidget类型
///
abstract class ListPageState<D extends DBBaseEntity, T extends StatefulWidget> extends State<T> {
  final StateController _controller = StateController();

  /// 加载的页数
  int _pageIndex = -1;

  /// 加载的数据
  final List<D> _list = [];

  @override
  void initState() {
    super.initState();

    /// 初始页面下标
    _pageIndex = initialPageIndex;
    _getData(); // 第一次加载数据
  }

  int get initialPageIndex => 1;

  @override
  Widget build(BuildContext context) {
    if (showAppBar) {
      return Scaffold(
        appBar: buildAppbar(),
        body: buildBody(),
      );
    }
    return buildBody();
  }

  bool get showAppBar => true;

  CommonBar buildAppbar() {
    return CommonBar(title: getTitle());
  }

  String getTitle() {
    return '';
  }

  Widget buildBody() {
    return Column(children: [
      Expanded(
        child: RefreshListView(
          controller: _controller,
          itemCount: _list.length,
          builder: (BuildContext context, int index) {
            return buildItem(_list[index], index);
          },
          refresh: _onRefresh,
          showFooter: true,
        ),
      ),
    ]);
  }

  Widget buildItem(D data, int index) {
    return Container();
  }

  /// [refresh]为true表示下拉刷新方法，为false表示上拉加载更多
  Future<void> _onRefresh(bool refresh) async {
    _pageIndex = (refresh ? initialPageIndex : _pageIndex);
    await _getData();
  }

  /// 加载数据，如果pageIndex为1表示从新加载
  Future<void> _getData() async {
    bool reset = _pageIndex == initialPageIndex;
    await Future.delayed(Duration(milliseconds: reset ? 500 : 0));
    await getData(_pageIndex);
  }

  /// 加载数据
  Future<void> getData(int pageIndex);

  /// 更新加载成功的状态
  void updateState(List<D> list, int? totalCount) {
    bool reset = _pageIndex == initialPageIndex;
    if (reset) {
      _list.clear();
    }
    if (_pageIndex >= (totalCount ?? 0)) {
      _controller.loadEmpty(); // 加载完所有页面
    } else {
      // 加载数据成功，保存数据，下次加载下一页
      _list.addAll(list);
      ++_pageIndex;
      _controller.loadMore();
    }
    if (mounted) setState(() {});
  }

  /// 更新加载失败的状态
  void updateFailedState() {
    _controller.loadFailed();
    if (mounted) setState(() {});
  }
}
