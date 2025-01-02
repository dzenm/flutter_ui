import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import 'images.dart';
import 'tap.dart';

/// 下载回调
typedef DownloadCallback = void Function(MediaEntity media);

/// Item图片创建器
typedef ItemBuilderDelegate = Widget Function(String url);

/// 图片展示对应的实体类
class MediaEntity<T> {
  String url;
  String? uid;
  bool isVideo;
  T? data;

  MediaEntity({required this.url, this.uid, this.isVideo = false, this.data});

  @override
  String toString() {
    return '$runtimeType='
        '{url: $url, '
        'uid: $uid, '
        'isVideo: $isVideo, '
        'data: ${data.toString()}}';
  }
}

/// 图片预览页面
class ViewMedia extends StatefulWidget {
  final List<MediaEntity> medias;
  final int initialItem;
  final ImageProvider<Object>? imageProvider;
  final TransitionBuilder? builder;
  final ItemBuilderDelegate? delegate;
  final DownloadCallback? onDownload;
  final BoxDecoration? decoration;
  final double initialScale;
  final bool showTurnPage;

  const ViewMedia({
    super.key,
    required this.medias,
    this.initialItem = 0,
    this.imageProvider,
    this.builder,
    this.delegate,
    this.onDownload,
    this.decoration,
    this.initialScale = 1.0,
    this.showTurnPage = true,
  });

  @override
  State<StatefulWidget> createState() => _ViewMediaState();
}

class _ViewMediaState extends State<ViewMedia> {
  final List<MediaEntity> _medias = [];
  int _currentIndex = 0;
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _medias.addAll(widget.medias);
    _currentIndex = widget.initialItem;

    _controller = PageController(
      initialPage: _currentIndex, //初始化第一次默认的位置
      keepPage: true, //是否保存当前Page的状态，如果保存，下次进入对应保存的page，如果为false。下次总是从initialPage开始。
      viewportFraction: 1.0, //占屏幕多少，1.0为占满整个屏幕
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        child: PhotoViewGestureDetectorScope(
          axis: Axis.horizontal,
          child: TapLayout(
            onLongPress: () => {},
            child: Stack(alignment: Alignment.center, children: [
              _buildPageView(),
              _buildBeforePageView(),
              _buildNextPageView(),
              _buildIndicatorView(),
              _buildDownloadPhotoView(),
            ]),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// PageView布局
  Widget _buildPageView() {
    return PageView.builder(
      scrollDirection: Axis.horizontal,
      reverse: false,
      controller: _controller,
      physics: const BouncingScrollPhysics(),
      // 是否具有回弹效果
      pageSnapping: true,
      allowImplicitScrolling: true,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      itemCount: _medias.length,
      itemBuilder: (BuildContext context, int index) {
        MediaEntity media = _medias[index];

        Widget child = _buildContent(media);

        if (widget.builder != null) {
          child = widget.builder!(context, child);
        }
        return PhotoView(
          backgroundDecoration: widget.decoration,
          imageProvider: widget.imageProvider ?? _defaultImageProvider(media.url),
          gaplessPlayback: true,
          wantKeepAlive: true,
          initialScale: PhotoViewComputedScale.contained * widget.initialScale,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.contained * 4,
          gestureDetectorBehavior: HitTestBehavior.translucent,
          scaleStateChangedCallback: (isZoom) {},
          loadingBuilder: (context, trunk) => child,
          errorBuilder: (context, object, trace) => child,
          onTapUp: (context, details, controllerValue) => Navigator.pop(context),
        );
      },
    );
  }

  Widget _buildContent(MediaEntity media) {
    String url = media.url;
    if (media.isVideo) {
      // return VideoLayout(url: url);
    }
    if (widget.delegate == null) {
      return ImageView(
        url: url,
        width: MediaQuery.of(context).size.width,
        isOrigin: true,
      );
    } else {
      return widget.delegate!(url);
    }
  }

  /// 默认加载图片提供者
  ImageProvider<Object> _defaultImageProvider(String url) {
    if (_isNetworkMedia(url)) {
      return CachedNetworkImageProvider(url, cacheManager: ImageCacheManager());
    } else if (_isPath(url)) {
      return FileImageExt(File(url));
    }
    return AssetImage(url);
  }

  /// 是否是网络图片
  bool _isNetworkMedia(String url) {
    return url.startsWith('https://') || url.startsWith('http://');
  }

  /// 是否是路径
  bool _isPath(String url) {
    return url.startsWith('/');
  }

  /// 图片位置指示器布局
  Widget _buildIndicatorView() {
    if (_medias.isEmpty || _medias.length == 1) {
      return const SizedBox.shrink();
    }
    return Positioned(
      bottom: 40,
      child: Row(children: [
        Text(
          '${_currentIndex + 1}/${_medias.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ]),
    );
  }

  /// 下载图片按钮布局
  Widget _buildDownloadPhotoView() {
    if (widget.onDownload == null) {
      return const SizedBox.shrink();
    }
    return Positioned(
      bottom: 40,
      right: 40,
      child: TapLayout(
        width: 32,
        height: 32,
        onTap: () {
          if (widget.onDownload != null) {
            widget.onDownload!(_medias[_currentIndex]);
          }
        },
        background: Colors.white38,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: const Icon(Icons.download_rounded, size: 24, color: Colors.white),
      ),
    );
  }

  /// 上一页图片按钮布局
  Widget _buildBeforePageView() {
    // 不展示翻页按钮，当前下标到了第一页
    if (!widget.showTurnPage || _currentIndex == 0) {
      return const SizedBox.shrink();
    }
    return Positioned(
      left: 24,
      child: TapLayout(
        width: 40,
        height: 40,
        isCircle: true,
        background: const Color(0xAA757575),
        onTap: () {
          _controller.jumpToPage(--_currentIndex);
          setState(() {});
        },
        child: const Icon(Icons.navigate_before, size: 32, color: Colors.white),
      ),
    );
  }

  /// 下一页图片按钮布局
  Widget _buildNextPageView() {
    // 不展示翻页按钮，当前下标到了最后一页
    if (!widget.showTurnPage || _currentIndex == _medias.length - 1) {
      return const SizedBox.shrink();
    }
    return Positioned(
      right: 24,
      child: TapLayout(
        width: 40,
        height: 40,
        isCircle: true,
        background: const Color(0xAA757575),
        onTap: () {
          _controller.jumpToPage(++_currentIndex);
          setState(() {});
        },
        child: const Icon(Icons.navigate_next, size: 32, color: Colors.white),
      ),
    );
  }
}
