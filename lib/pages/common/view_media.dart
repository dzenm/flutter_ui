import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';


///
/// Created by a0010 on 2024/1/10 15:32
///
class ViewMediaPage extends StatelessWidget {
  final Object? tag;
  final List<ImageEntity> medias;
  final int initialItem;
  final ImageProvider<Object>? imageProvider;
  final DownloadCallback? onDownload;
  final BoxDecoration? decoration;
  final bool showTurnPage;

  const ViewMediaPage({
    super.key,
    this.tag,
    required this.medias,
    this.initialItem = 0,
    this.imageProvider,
    this.onDownload,
    this.decoration,
    this.showTurnPage = true,
  });

  /// 跳转图片预览页面
  static Future<T?> show<T>(
    BuildContext context, {
    Object? tag,
    required List<ImageEntity> medias,
    ImageProvider<Object>? imageProvider,
    int initialItem = 0,
    DownloadCallback? onDownload,
    BoxDecoration? decoration,
    bool showTurnPage = false,
    AnimatorStyle animator = AnimatorStyle.fade,
  }) async {
    return await Navigator.of(context).push<T>(
      CustomerPageRoute<T>(
        ViewMediaPage(
          tag: tag,
          medias: medias,
          initialItem: initialItem,
          imageProvider: imageProvider,
          onDownload: onDownload,
          decoration: decoration,
          showTurnPage: showTurnPage,
        ),
        style: animator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    TransitionBuilder? builder;
    if (tag != null) {
      builder = (BuildContext context, Widget? child) {
        return Hero(tag: tag!, child: child!);
      };
    }
    return ViewMedia(
      medias: medias,
      initialItem: initialItem,
      imageProvider: imageProvider,
      builder: builder,
      onDownload: onDownload,
      decoration: decoration,
      showTurnPage: showTurnPage,
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
            return _buildTransition(style, context, animation, secondaryAnimation, child);
          },
        );

  static Widget _buildTransition(style, context, animation, secondaryAnimation, child) {
    if (style == AnimatorStyle.fade) {
      //逐渐消失的动画效果
      return FadeTransition(
        opacity: Tween(begin: 0.0, end: 1.0) //设置透明度
            .chain(CurveTween(curve: Curves.ease))
            .animate(animation),
        child: child,
      );
    } else if (style == AnimatorStyle.scale) {
      //缩放的动画效果
      return ScaleTransition(
        scale: Tween(begin: 0.7, end: 1.0) //设置缩放比例
            .chain(CurveTween(curve: Curves.ease))
            .animate(animation),
        child: child,
      );
    } else if (style == AnimatorStyle.translate) {
      //左右滑动动画效果
      return SlideTransition(
        position: Tween(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0)) //设置滑动起点和终点
            .chain(CurveTween(curve: Curves.easeInCubic))
            .animate(animation),
        child: child,
      );
    } else {
      //旋转+缩放动画效果
      return RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0) //设置不透明度
            .chain(CurveTween(curve: Curves.ease))
            .animate(animation),
        child: ScaleTransition(
          scale: Tween(begin: 0.0, end: 1.0) //设置不透明度
              .chain(CurveTween(curve: Curves.ease))
              .animate(animation),
          child: child,
        ),
      );
    }
  }
}

/// 页面跳转的动画样式
enum AnimatorStyle {
  fade,
  scale,
  translate,
  rotation,
}
