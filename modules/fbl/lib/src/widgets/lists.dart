import 'dart:io';

import 'package:flutter/material.dart';

import 'states.dart';

///
/// Created by a0010 on 2024/12/30 15:58
/// 指示器的通用组件
///

typedef RefreshFunction = Future<void> Function(bool refresh);

class SelectedEntity<T> {
  T data;
  bool isSelected = false;

  SelectedEntity({required this.data, this.isSelected = false});
}

/// 带下拉刷新的[ListView]
/// RefreshListView(
///   controller: _controller,
///   itemCount: _list.length,
///   builder: (BuildContext context, int index) {
///    return buildItem(_list[index], index);
///   },
///   refresh: _onRefresh,
///   showFooter: true,
/// )
class RefreshListView extends StatefulWidget {
  final StateController? controller; // 加载状态控制器
  final int itemCount; // item数量
  final IndexedWidgetBuilder builder; // 子item样式
  final RefreshFunction? refresh; // refresh为true表示下拉刷新的回调, 为false表示上拉加载更多的回调
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool showFooter;
  final bool slideListener;

  const RefreshListView({
    super.key,
    required this.itemCount,
    required this.builder,
    this.refresh,
    this.controller,
    this.physics,
    this.padding,
    this.showFooter = false,
    this.slideListener = true,
  });

  @override
  State<StatefulWidget> createState() => _RefreshListViewState();
}

class _RefreshListViewState extends State<RefreshListView> {
  final ScrollController _controller = ScrollController(); // listView的控制器
  StateController? _stateController;
  bool _isTouch = false; // 手指是否已经触摸到屏幕
  bool _isFooter = false; // 是否滑动到最底部
  bool _isLoading = false; // 是否正在加载数据中

  @override
  void initState() {
    super.initState();

    _stateController = widget.controller ?? StateController();
    _controller.addListener(() {
      // 如果正在加载数据中，不处理
      if (_isLoading) return;
      // pixels：当前滚动的像素点
      // maxScrollExtent：当前最大可滚动的位置
      // 判断是否滑动到最底部
      _isFooter = _controller.position.pixels >= _controller.position.maxScrollExtent;
      // 手指已离开屏幕并且滑动到底部时加载更多数据
      if (_isFooter) {
        _loadingMore();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 初始时，显示加载状态，如加载成功后隐藏页面并显示数据，之后显示加载更多

    // 根据列表数量判断是否初始化
    bool isInit = widget.itemCount != 0;
    // 列表数量
    int itemCount = widget.itemCount + (!widget.showFooter ? 0 : 1);
    Widget child = const SizedBox.shrink();
    if (isInit) {
      if (widget.refresh != null) {
        child = RefreshIndicator(
          onRefresh: _refresh,
          child: _buildListView(itemCount),
        );
      } else {
        child = _buildListView(itemCount);
      }
    }
    child = StateView(
      controller: _stateController!,
      onTap: () => _refresh(isInit: isInit),
      child: child,
    );

    if (!widget.slideListener) {
      return child;
    }
    return Listener(
      // 手指按下屏幕
      onPointerDown: (event) => _isTouch = true,
      // 手指按下屏幕未离开并且在滑动
      onPointerMove: (event) {
        // 未初始化/正在加载中时，不处理
        if (!isInit || _isLoading || !_isTouch) return;
        // 手指移动过程中，如果已经到最底部了，就提示松开手指进行加载，如果未滑动到最底部就提示继续滑动
        if (_isFooter) {
          _stateController!.loadMore();
        } else {
          _stateController!.loadSliding();
        }
        setState(() {});
      },
      // 手指离开屏幕
      onPointerUp: (event) {
        // 未初始化/正在加载中时，不处理
        if (!isInit || _isLoading) return;
        _isTouch = false;
        // 手指已离开屏幕并且滑动到底部时加载更多数据
        if (_isFooter) {
          _loadingMore();
        }
      },
      child: child,
    );
  }

  Widget _buildListView(int itemCount) {
    return ListView.builder(
      itemBuilder: _buildItem,
      itemCount: itemCount,
      physics: widget.physics,
      padding: widget.padding,
      controller: _controller,
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
  Future<void> _refresh({bool isInit = true}) async {
    if (!isInit) setState(() => _stateController!.loading());
    if (widget.refresh != null) {
      await widget.refresh!(true);
    }
  }

  /// 加载更多的数据
  Future<void> _loadingMore() async {
    // 正在加载中/正在触摸屏幕时，不处理（防止多次处理）
    if (_isLoading || _isTouch) return;

    _isLoading = true;
    setState(() => _stateController!.loading());
    if (widget.refresh != null) {
      await widget.refresh!(false);
    }
    _isLoading = false;
  }
}

/// 分割线
class DividerView extends StatelessWidget {
  final double height;
  final double width;
  final double indent;
  final double endIndent;
  final Color color;
  final Direction direction;

  const DividerView({
    super.key,
    this.height = 0.1,
    this.width = 0.1,
    this.indent = 0,
    this.endIndent = 0,
    this.color = const Color(0xFFF5F5F5),
    this.direction = Direction.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    switch (direction) {
      case Direction.vertical:
        return VerticalDivider(
          width: width,
          indent: indent,
          endIndent: endIndent,
          color: color,
        );
      case Direction.horizontal:
        return Divider(
          height: height,
          indent: indent,
          endIndent: endIndent,
          color: color,
        );
    }
  }
}

/// 方向
enum Direction {
  vertical,
  horizontal,
}

/// 统一滚动控件
class ScrollConfigurationWidget extends StatelessWidget {
  final Widget child;

  const ScrollConfigurationWidget(
      this.child, {
        super.key,
      });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollBehave(),
      child: Scrollbar(
        thickness: 5, //宽度
        radius: const Radius.circular(5), //圆角
        child: child,
      ),
    );
  }
}

/// 安卓系统去除滑动控件上下的蓝色水波纹
class ScrollBehave extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context,
      Widget child,
      ScrollableDetails details,
      ) {
    if (Platform.isAndroid || Platform.isFuchsia) {
      return child;
    } else {
      return super.buildOverscrollIndicator(context, child, details);
    }
  }
}