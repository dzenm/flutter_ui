import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

import '../base.dart';

/// 下载回调
typedef DownloadCallback = void Function(MediaEntity media);

/// 图片展示对应的实体类
class MediaEntity<T> {
  String url;
  String? uid;
  T? data;

  MediaEntity({required this.url, this.uid, this.data});
}

/// 图片预览页面
class ViewMedia extends StatefulWidget {
  final List<MediaEntity> medias;
  final int initialItem;
  final ImageProvider<Object>? imageProvider;
  final DownloadCallback? onDownload;

  const ViewMedia({
    super.key,
    required this.medias,
    this.initialItem = 0,
    this.imageProvider,
    this.onDownload,
  });

  @override
  State<StatefulWidget> createState() => _ViewMediaState();
}

class _ViewMediaState extends State<ViewMedia> {
  final List<MediaEntity> _medias = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _medias.addAll(widget.medias);
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
            _buildIndicatorView(),
            _buildDownloadPhotoView(),
          ]),
        ),
      ),
    );
  }

  /// PageView布局
  Widget _buildPageView() {
    return PageView.builder(
      scrollDirection: Axis.horizontal,
      reverse: false,
      controller: PageController(
        initialPage: _currentIndex, //初始化第一次默认的位置
        keepPage: true, //是否保存当前Page的状态，如果保存，下次进入对应保存的page，如果为false。下次总是从initialPage开始。
        viewportFraction: 1.0, //占屏幕多少，1.0为占满整个屏幕
      ),
      physics: const BouncingScrollPhysics(),
      // 是否具有回弹效果
      pageSnapping: true,
      allowImplicitScrolling: true,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      itemCount: _medias.length,
      itemBuilder: (BuildContext context, int index) {
        MediaEntity media = _medias[index];

        String url = media.url;
        Widget thumbChild = ImageView(
          url: url,
          width: MediaQuery.of(context).size.width,
          origin: true,
        ); //缩略图先展示,无缩略图展示原图

        return PhotoView(
          imageProvider: widget.imageProvider ?? _defaultImageProvider(media.url),
          gaplessPlayback: true,
          wantKeepAlive: true,
          initialScale: PhotoViewComputedScale.contained,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.contained * 5,
          gestureDetectorBehavior: HitTestBehavior.translucent,
          scaleStateChangedCallback: (isZoom) {},
          loadingBuilder: (context, trunk) => thumbChild,
          errorBuilder: (context, object, trace) => thumbChild,
          onTapUp: (context, details, controllerValue) => Navigator.pop(context),
        );
      },
    );
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
    if (_medias.isEmpty) {
      return Container();
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
      return Container();
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
}
