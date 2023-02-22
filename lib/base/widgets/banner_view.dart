import 'dart:async';

import 'package:flutter/material.dart';

/// Item的点击事件
typedef void ItemClick(int position);

/// 自定义指示器布局
typedef Widget IndicatorItemViewBuilder(int position, int selected);

/// 自定义页面显示的布局
typedef Widget ItemViewBuilder(dynamic data);

/// 轮播图展示
class BannerView extends StatefulWidget {
  final double? width;
  final double? height;
  final ItemViewBuilder builder;
  final List<BannerData> data;
  final Duration duration;
  final double indicatorSize;
  final Alignment indicatorAlignment;
  final bool autoPlay;
  final IndicatorItemViewBuilder? indicatorBuilder;
  final ItemClick? onTap;

  BannerView({
    Key? key,
    required this.builder,
    required this.data,
    this.width,
    this.height = 200,
    this.duration = const Duration(seconds: 3),
    this.indicatorSize = 8.0,
    this.indicatorAlignment = Alignment.topRight,
    this.autoPlay = true,
    this.indicatorBuilder,
    this.onTap,
  }) : super(key: key);

  State<StatefulWidget> createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView> {
  PageController _controller = PageController();

  /// 内部加两个⻚⾯ +B(A,B)+A
  List<Widget> _banners = [];

  /// 定时滑动页面的计时器
  Timer? _timer;

  /// 实际数据的长度
  int _realLen = 0;

  /// 当前页面在[_banners]中的索引
  int _curPageIndex = 0;

  @override
  void initState() {
    super.initState();

    _resetPage();
  }

  @override
  void didUpdateWidget(covariant BannerView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 更改children状态，需要重新初始化。
    if (isUpdate(oldWidget.data, widget.data)) {
      _resetPage();
    }
    if (oldWidget.autoPlay != widget.autoPlay) {
      if (widget.autoPlay) {
        _autoPlayPage();
      } else {
        _timer?.cancel();
      }
    }
  }

  bool isUpdate(List oldList, List newList) {
    if (oldList.length != newList.length) {
      return true;
    }
    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i] != newList[i]) {
        return true;
      }
    }
    return false;
  }

  void _resetPage() {
    _realLen = widget.data.length;
    if (_realLen == 0) {
      return;
    }

    _banners.clear();
    // 初始化数据
    List<Widget> children = [];
    widget.data.forEach((banner) => children.add(widget.builder(banner.data)));
    _banners.addAll(children);

    // 定时器完成⾃动翻⻚
    if (_realLen > 1) {
      // 如果⼤于⼀⻚，则会在前后都加⼀⻚
      _banners.insert(0, children.last);
      _banners.add(children.first);

      // 初始⻚要是1
      _curPageIndex = 1;
      _autoPlayPage();

      // 初始⻚⾯ 指定
      Future.delayed(Duration.zero, () => _controller.jumpToPage(_curPageIndex));
    }
  }

  // 自动更换页面
  void _autoPlayPage() {
    if (widget.autoPlay && _realLen > 1) {
      _timer?.cancel();
      _timer = Timer.periodic(widget.duration, _nextPage);
    }
  }

  // 进入下一页
  void _nextPage(Timer timer) {
    ++_curPageIndex;
    _curPageIndex = _curPageIndex == _banners.length ? 0 : _curPageIndex;
    _controller.animateToPage(_curPageIndex, duration: Duration(milliseconds: 500), curve: Curves.linear);
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_realLen == 0) return Container();
    return Container(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          _buildBannerView(),
          _buildIndicatorView(),
          _buildTitleView(),
        ],
      ),
    );
  }

  // Banner页面
  Widget _buildBannerView() {
    return _listener(PageView.builder(
      itemCount: _banners.length,
      controller: _controller,
      onPageChanged: (int index) {
        if (_realLen > 1) {
          // 需要更新下下标
          setState(() => _curPageIndex = index);
        }
      },
      itemBuilder: (context, index) {
        return Material(
          child: InkWell(
            child: _banners[index],
            onTap: () {
              if (_banners.length > 1 && widget.onTap != null) {
                widget.onTap!(_curPageIndex - 1);
              }
            },
          ),
        );
      },
    ));
  }

  // 监听页面的切换
  Widget _listener(Widget child) {
    return Listener(
      onPointerDown: (PointerDownEvent event) => _timer?.cancel(), // 手指放下时，取消自动换页定时器
      onPointerUp: (PointerUpEvent event) => _autoPlayPage(), // 手指抬起时，启动自动换页定时器
      child: NotificationListener(
        child: child,
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            // 是⼀个完整⻚⾯的偏移
            if (notification.metrics.atEdge) {
              // 如果是实际中的第一页或最后一页，需要重新调整它所在的位置
              _controller.jumpToPage(_getRealIndex(isStartZero: false));
            }
          }
          return false;
        },
      ),
    );
  }

  // 一组指示器布局
  Widget _buildIndicatorView() {
    List<Widget> indicators = [];
    for (int i = 0; i < _realLen; i++) {
      Widget child = (widget.indicatorBuilder ?? _buildIndicatorItemView)(_getRealIndex(), i);
      indicators.add(child);
    }
    return Align(
      alignment: widget.indicatorAlignment,
      child: IntrinsicHeight(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: indicators,
          ),
        ),
      ),
    );
  }

  // 单个指示器布局
  Widget _buildIndicatorItemView(int selectedIndex, int i) {
    bool selected = selectedIndex == i;
    Color color = selected ? Colors.white : Colors.grey;
    return Container(
      margin: EdgeInsets.all(3.0),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  // 标题布局
  Widget _buildTitleView() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: IntrinsicHeight(
        child: Container(
          color: Color(0x99000000),
          padding: EdgeInsets.all(6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_buildTitleItemView()],
          ),
        ),
      ),
    );
  }

  // 单个标题布局
  Widget _buildTitleItemView() {
    BannerData banner = widget.data[_getRealIndex()];
    if (banner.title?.isEmpty ?? false) return Container();
    return Expanded(
      child: Text(
        banner.title ?? '',
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white, fontSize: 12.0),
      ),
    );
  }

  // 获取实际页面的索引
  int _getRealIndex({bool isStartZero = true}) {
    int index = _curPageIndex;
    if (_curPageIndex == 0) {
      // 如果索引是children中的第⼀⻚，它显示的是实际中最后一页的内容，在children的索引是children.length - 2
      index = _banners.length - 2;
    } else if (_curPageIndex == _banners.length - 1) {
      // 如果索引是children中的最后⼀⻚，它显示的是实际中第一页的内容，在children的索引是1
      index = 1;
    }
    return isStartZero ? index - 1 : index;
  }
}

// Banner数据结构
class BannerData {
  String? title;
  dynamic data;

  BannerData({this.title, this.data});
}
