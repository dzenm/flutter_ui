import 'dart:async';

import 'package:flutter/material.dart';

/// 自定义页面显示的布局
typedef ItemBuilder = Widget Function(dynamic data);

/// Item的点击事件
typedef ItemClick = void Function(int position);

/// 自定义布局的其他属性
typedef ParentBuilder = Widget Function(Widget child);

/// 自定义指示器布局
typedef IndicatorItemBuilder = Widget Function(bool isSelected);

///
/// 轮播图展示
/// BannerView(
///   repeat: true,
///   builder: (imagePath) => Image.network(imagePath ?? '', fit: BoxFit.cover),
///   data: banners.map((banner) => BannerData(title: banner.title, data: banner.imagePath)).toList(),
///   onTap: (index) {
///     BannerEntity banner = banners[index];
///     String params = '?title=${banner.title}&url=${banner.url}';
///     AppRouter.of(context).push(Routers.webView + params);
///   },
/// )
class BannerView extends StatefulWidget {
  final ItemBuilder builder;
  final List<BannerData> data;
  final double? width;
  final double? height;
  final Duration duration;
  final bool autoPlay;
  final bool repeat;
  final ParentBuilder? titleParentBuilder;
  final double indicatorSize;
  final ParentBuilder? indicatorParentBuilder;
  final IndicatorItemBuilder? indicatorItemBuilder;
  final ItemClick? onTap;

  const BannerView({
    super.key,
    required this.builder,
    required this.data,
    this.width,
    this.height = 200,
    this.duration = const Duration(seconds: 3),
    this.autoPlay = true,
    this.repeat = false,
    this.titleParentBuilder,
    this.indicatorSize = 8.0,
    this.indicatorParentBuilder,
    this.indicatorItemBuilder,
    this.onTap,
  });

  @override
  State<StatefulWidget> createState() => _BannerViewState();
}

class _BannerViewState extends State<BannerView> {
  final PageController _controller = PageController();

  /// 内部加两个⻚⾯ +B(A,B)+A
  final List<Widget> _banners = [];

  /// 当前页面在[_banners]中的索引
  int _curPageIndex = 0;

  /// 定时滑动页面的计时器
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _resetPage();
  }

  @override
  void didUpdateWidget(covariant BannerView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 更改children状态，需要重新初始化。
    if (_isUpdate(oldWidget.data, widget.data)) {
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

  /// 是否需要更新，如果数据集发生变化，则返回true，否则false
  bool _isUpdate(List oldList, List newList) {
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

  /// 重置页面
  void _resetPage() {
    if (realPageLength == 0) return;

    _banners.clear();
    // 初始化数据
    List<Widget> children = [];
    for (var banner in widget.data) {
      children.add(widget.builder(banner.data));
    }
    _banners.addAll(children);

    // 如果打开周期翻页的开关并且页面的长度内容大于两页时，在定时器完成进行⾃动翻⻚
    if (widget.repeat && realPageLength > 1) {
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

  /// 真正的页面列表的长度(展示传入的数据长度)
  int get realPageLength => widget.data.length;

  /// 自动更换页面
  void _autoPlayPage() {
    if (widget.autoPlay && realPageLength > 1) {
      _timer?.cancel();
      _timer = Timer.periodic(widget.duration, (Timer timer) {
        // 自动翻页
        ++_curPageIndex;
        _curPageIndex = _curPageIndex == _banners.length ? 0 : _curPageIndex;
        _controller.animateToPage(
          _curPageIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear,
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (realPageLength == 0) {
      return const SizedBox.shrink();
    }
    return SizedBox(
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

  /// Banner页面
  Widget _buildBannerView() {
    // 监听页面的切换
    return Listener(
      onPointerDown: (PointerDownEvent event) => _timer?.cancel(), // 手指放下时，取消自动换页定时器
      onPointerUp: (PointerUpEvent event) => _autoPlayPage(), // 手指抬起时，启动自动换页定时器
      child: NotificationListener(
        child: PageView.builder(
          itemCount: _banners.length,
          controller: _controller,
          onPageChanged: (int index) {
            if (realPageLength > 1) {
              // 需要更新下下标
              setState(() => _curPageIndex = index);
              // 如果是实际中的第一页或最后一页，需要重新调整它所在的位置
              // TODO 无法使用动画，否则滑动过快会报错
              // _controller.jumpToPage(_getRealPageIndex(isStartZero: false));
              // _controller.animateToPage(
              //   _getRealPageIndex(isStartZero: false),
              //   duration: Duration(milliseconds: 200),
              //   curve: Curves.linear,
              // );
            }
          },
          itemBuilder: (context, index) {
            return Material(
              child: InkWell(
                child: _banners[index],
                onTap: () {
                  if (_banners.length > 1 && widget.onTap != null) {
                    widget.onTap!(_getRealPageIndex(isStartZero: true));
                  }
                },
              ),
            );
          },
        ),
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            // 滚动开始
          } else if (notification is ScrollUpdateNotification) {
            // 滚动中
            if (notification.metrics.atEdge) {
              // 如果是实际中的第一页或最后一页，需要重新调整它所在的位置
              _controller.jumpToPage(_getRealPageIndex(isStartZero: false));
            }
          } else if (notification is ScrollEndNotification) {
            //滚动结束
          }
          return false;
        },
      ),
    );
  }

  /// 一组指示器布局
  Widget _buildIndicatorView() {
    List<Widget> indicators = [];
    for (int i = 0; i < realPageLength; i++) {
      bool selected = _getRealPageIndex() == i;
      Widget child = (widget.indicatorItemBuilder ?? _buildIndicatorItemView)(selected);
      indicators.add(child);
    }
    Widget child = Row(
      mainAxisSize: MainAxisSize.min,
      children: indicators,
    );
    if (widget.indicatorParentBuilder != null) {
      return widget.indicatorParentBuilder!(child);
    }
    return Align(
      alignment: Alignment.topRight,
      child: IntrinsicHeight(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: child,
        ),
      ),
    );
  }

  /// 单个指示器布局
  Widget _buildIndicatorItemView(bool isSelected) {
    Color color = isSelected ? Colors.white : Colors.grey;
    return Container(
      margin: const EdgeInsets.all(3.0),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  /// 标题布局
  Widget _buildTitleView() {
    BannerData banner = widget.data[_getRealPageIndex()];
    String? title = banner.title;
    if (title?.isEmpty ?? false) return const SizedBox.shrink();

    Widget child = Text(
      title!,
      softWrap: true,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(color: Colors.white, fontSize: 12.0),
    );
    if (widget.titleParentBuilder != null) {
      return widget.titleParentBuilder!(child);
    }
    return Align(
      alignment: Alignment.bottomCenter,
      child: IntrinsicHeight(
        child: Container(
          color: const Color(0x99000000),
          padding: const EdgeInsets.all(6.0),
          child: Row(children: [Expanded(child: child)]),
        ),
      ),
    );
  }

  // 获取实际页面的索引
  int _getRealPageIndex({bool isStartZero = true}) {
    if (!widget.repeat) {
      return _curPageIndex;
    }
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
