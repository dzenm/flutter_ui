import 'dart:async';

import 'package:flutter/material.dart';

/// Item的点击事件
typedef void ItemClick(int position);

/// 自定义指示器布局
typedef Widget IndicatorView(int position, int selected);

/// 轮播图展示
class BannerView extends StatefulWidget {
  final double? width;
  final double? height;
  final List<Widget> children;
  final Duration switchDuration;
  final double indicatorSize;
  final Alignment indicatorAlignment;
  final bool autoPlay;
  final List<String>? titles;
  final IndicatorView? indicator;
  final ItemClick? onTap;

  BannerView({
    Key? key,
    this.width,
    this.height = 200,
    this.children = const <Widget>[],
    this.switchDuration = const Duration(seconds: 3),
    this.indicatorSize = 8.0,
    this.indicatorAlignment = Alignment.topRight,
    this.autoPlay = true,
    this.titles,
    this.indicator,
    this.onTap,
  }) : super(key: key);

  State<StatefulWidget> createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView> {
  List<Widget> _children = []; // 内部加两个⻚⾯ +B(A,B)+A
  PageController _pageController = PageController();
  Timer? _timer;
  int _realLength = 0;
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
    if (isUpdate(oldWidget.children, widget.children)) {
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
    _realLength = widget.children.length;
    if (_realLength == 0) {
      return;
    }
    _children.clear();
    _children.addAll(widget.children);

    // 定时器完成⾃动翻⻚
    if (_realLength > 1) {
      // 如果⼤于⼀⻚，则会在前后都加⼀⻚
      _children.insert(0, widget.children.last);
      _children.add(widget.children.first);

      // 初始⻚要是1
      _curPageIndex = 1;
      _autoPlayPage();

      // 初始⻚⾯ 指定
      Future.delayed(Duration.zero, () => _pageController.jumpToPage(_curPageIndex));
    }
  }

  // 自动更换页面
  void _autoPlayPage() {
    if (widget.autoPlay && _realLength > 1) {
      _timer?.cancel();
      _timer = Timer.periodic(widget.switchDuration, _nextPage);
    }
  }

  // 进入下一页
  void _nextPage(Timer timer) {
    ++_curPageIndex;
    _curPageIndex = _curPageIndex == _children.length ? 0 : _curPageIndex;
    _pageController.animateToPage(_curPageIndex, duration: Duration(milliseconds: 500), curve: Curves.linear);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          _bannerView(),
          _indicator(),
          _titleView(),
        ],
      ),
    );
  }

  // Banner页面
  Widget _bannerView() {
    return _listener(PageView.builder(
      itemCount: _children.length,
      controller: _pageController,
      onPageChanged: (int index) {
        if (_realLength > 1) {
          // 需要更新下下标
          setState(() => _curPageIndex = index);
        }
      },
      itemBuilder: (context, index) {
        return Material(
          child: InkWell(
            child: _children[index],
            onTap: () {
              if (_children.length > 1 && widget.onTap != null) {
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
              _pageController.jumpToPage(_getRealIndex(isStartZero: false));
            }
          }
          return false;
        },
      ),
    );
  }

  // 一组指示器布局
  Widget _indicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < _realLength; i++) {
      Widget child = (widget.indicator ?? _createIndicator)(_getRealIndex(), i);
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
  Widget _createIndicator(int selectedIndex, int i) {
    return Container(
      margin: EdgeInsets.all(3.0),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selectedIndex == i ? Colors.white : Colors.grey,
      ),
    );
  }

  // 标题布局
  Widget _titleView() {
    if (widget.titles == null || widget.titles!.isEmpty) return Container();
    return Align(
      alignment: Alignment.bottomCenter,
      child: IntrinsicHeight(
        child: Container(
          color: Color(0x99000000),
          padding: EdgeInsets.all(6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.titles![_getRealIndex()],
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 12.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 获取实际页面的索引
  int _getRealIndex({bool isStartZero = true}) {
    if (_realLength <= 1) {
      return 0;
    }
    int index = _curPageIndex;
    if (_curPageIndex == 0) {
      // 如果索引是children中的第⼀⻚，它显示的是实际中最后一页的内容，在children的索引是children.length - 2
      index = _children.length - 2;
    } else if (_curPageIndex == _children.length - 1) {
      // 如果索引是children中的最后⼀⻚，它显示的是实际中第一页的内容，在children的索引是1
      index = 1;
    }
    return isStartZero ? index - 1 : index;
  }
}
