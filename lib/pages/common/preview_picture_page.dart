import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../../base/base.dart';

typedef DownloadCallback = void Function(String url);

/// 图片预览页面
class PreviewPicturePage extends StatefulWidget {
  final List<String> url;
  final int initialItem;
  final ImageProvider<Object>? imageProvider;
  final DownloadCallback? onDownload;

  const PreviewPicturePage(
    this.url, {
    super.key,
    this.initialItem = 0,
    this.imageProvider,
    this.onDownload,
  });

  /// 跳转图片预览页面
  static Future<T?> show<T>(
    BuildContext context,
    List<String> url, {
    ImageProvider<Object>? imageProvider,
    int initialItem = 0,
    DownloadCallback? onDownload,
    AnimatorStyle animator = AnimatorStyle.fade,
  }) async {
    return await Navigator.of(context).push<T>(
      CustomerPageRoute<T>(
        PreviewPicturePage(
          url,
          initialItem: initialItem,
          imageProvider: imageProvider,
          onDownload: onDownload,
        ),
        style: animator,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _PreviewPicturePageState();
}

class _PreviewPicturePageState extends State<PreviewPicturePage> {
  final List<dynamic> _list = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _list.addAll(widget.url);
    _currentIndex = widget.initialItem;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PhotoViewGestureDetectorScope(
        axis: Axis.horizontal,
        child: TapLayout(
          onLongPress: () => {},
          child: Stack(alignment: Alignment.center, children: [
            _buildPageView(),
            _buildIndicator(),
            _buildDownloadPhoto(),
          ]),
        ),
      ),
    );
  }

  /// 创建PageView
  Widget _buildPageView() {
    return PageView(
      scrollDirection: Axis.horizontal,
      reverse: false,
      controller: PageController(
        initialPage: _currentIndex, //初始化第一次默认的位置
        viewportFraction: 1, //占屏幕多少，1为占满整个屏幕
        keepPage: true, //是否保存当前Page的状态，如果保存，下次进入对应保存的page，如果为false。下次总是从initialPage开始。
      ),
      physics: const BouncingScrollPhysics(),
      // 是否具有回弹效果
      pageSnapping: true,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      children: _list.map((url) {
        return PhotoView(
          imageProvider: widget.imageProvider ?? _imageProvider(url),
          initialScale: PhotoViewComputedScale.contained,
          wantKeepAlive: true,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.contained * 3,
          gestureDetectorBehavior: HitTestBehavior.translucent,
          scaleStateChangedCallback: (isZoom) {},
          onTapUp: (context, details, controllerValue) => Navigator.pop(context),
        );
      }).toList(),
    );
  }

  /// 加载图片
  ImageProvider<Object> _imageProvider(String url) {
    if (_isNetworkImage(url)) {
      return NetworkImage(url);
    }
    return AssetImage(url);
  }

  /// 是否是网络图片
  bool _isNetworkImage(String url) {
    return url.startsWith('https://') || url.startsWith('http://');
  }

  /// 创建指示器
  Widget _buildIndicator() {
    return Positioned(
      bottom: 40,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Offstage(
          offstage: _list.isEmpty,
          child: Text(
            '${_currentIndex + 1}/${_list.length}',
            style: const TextStyle(color: Colors.white),
          ),
        )
      ]),
    );
  }

  Widget _buildDownloadPhoto() {
    return Positioned(
      bottom: 40,
      right: 40,
      child: Offstage(
        offstage: widget.onDownload == null,
        child: TapLayout(
          width: 32,
          height: 32,
          onTap: () {
            if (widget.onDownload != null) {
              widget.onDownload!(_list[_currentIndex]);
            }
          },
          background: Colors.white38,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: const Icon(Icons.download_rounded, size: 24, color: Colors.white),
        ),
      ),
    );
  }
}

/// 自定义动画样式
class CustomerPageRoute<T> extends PageRouteBuilder<T> {
  final Widget widget;
  final AnimatorStyle style;

  CustomerPageRoute(
    this.widget, {
    this.style = AnimatorStyle.fade,
  }) : super(
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation1, secondaryAnimation) {
            return widget;
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (style == AnimatorStyle.fade) {
              //逐渐消失的动画效果
              return FadeTransition(
                opacity: Tween(begin: 0.0, end: 1.0) //设置透明度
                    .animate(CurvedAnimation(parent: animation, curve: Curves.linear)),
                child: child,
              );
            } else if (style == AnimatorStyle.scale) {
              //缩放的动画效果
              return ScaleTransition(
                scale: Tween(begin: 0.7, end: 1.0) //设置缩放比例
                    .animate(CurvedAnimation(parent: animation, curve: Curves.linear)),
                child: child,
              );
            } else if (style == AnimatorStyle.translate) {
              //左右滑动动画效果
              return SlideTransition(
                position: Tween(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0)) //设置滑动起点和终点
                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: child,
              );
            } else {
              //旋转+缩放动画效果
              return RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0) //设置不透明度
                    .animate(CurvedAnimation(parent: animation, curve: Curves.linear)),
                child: ScaleTransition(
                  scale: Tween(begin: 0.0, end: 1.0) //设置不透明度
                      .animate(CurvedAnimation(parent: animation, curve: Curves.linear)),
                  child: child,
                ),
              );
            }
          },
        );
}

/// 页面跳转的动画样式
enum AnimatorStyle {
  fade,
  scale,
  translate,
  rotation,
}
