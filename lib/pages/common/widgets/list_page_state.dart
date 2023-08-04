import 'package:flutter/material.dart';

import '../../../base/db/db_base_model.dart';
import '../../../base/widgets/common_bar.dart';
import '../../../base/widgets/refresh_list_view.dart';
import '../../../base/widgets/state_view.dart';

///
/// Created by a0010 on 2023/2/23 13:35
/// 列表页面State
/// 页面UI只有一个带 [RefreshIndicator] 的 [ListView] ，请求数据实现 [ListPageState.getData] ，
/// 创建 [ListView] Item实现 [ListPageState.buildItem]，修改 [CommonBar] 实现 [ListPageState.buildAppbar]
///
/// 创建自己的 [State] 直接继承 [ListPageState]，[D] 为列表的数据结构类型，[T] 为StateWidget类型
///
class ListPageState<D extends DBBaseModel, T extends StatefulWidget> extends State<T> {
  final StateController _controller = StateController();
  int _pageIndex = 1; // 加载的页数
  final List<D> _list = []; // 加载的数据

  @override
  void initState() {
    super.initState();

    getData(reset: true); // 第一次加载数据
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppbar(),
      body: buildBody(),
    );
  }

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
          refresh: onRefresh,
          showFooter: true,
        ),
      ),
    ]);
  }

  Widget buildItem(D data, int index) {
    return Container();
  }

  // 下拉刷新方法,为list重新赋值
  Future<void> onRefresh(bool refresh) async => getData(reset: refresh);

  // 根据页数获取收藏
  Future<void> getData({bool reset = false}) async {
    if (reset) {
      _list.clear();
      _pageIndex = 1;
    }
    await Future.delayed(Duration(milliseconds: reset ? 500 : 0));
  }

  // 获取数据
  List<D> get data => _list;

  // 更新数据
  set data(List<D> list) {
    _list.addAll(list);
  }

  // 获取请求页数下标
  int get pageIndex => _pageIndex;

  // 更新请求页数下标
  void updatePage() {
    _pageIndex++;
  }

  StateController get controller => _controller;
}
