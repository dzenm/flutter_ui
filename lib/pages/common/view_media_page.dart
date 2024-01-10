import 'package:flutter/material.dart';

import '../../base/widgets/widget.dart';

///
/// Created by a0010 on 2024/1/10 15:32
///
class ViewMediaPage extends StatelessWidget {
  final List<MediaEntity> medias;
  final int initialItem;
  final ImageProvider<Object>? imageProvider;
  final DownloadCallback? onDownload;

  const ViewMediaPage({
    super.key,
    required this.medias,
    this.initialItem = 0,
    this.imageProvider,
    this.onDownload,
  });

  /// 跳转图片预览页面
  static Future<T?> show<T>(
    BuildContext context, {
    required List<MediaEntity> medias,
    ImageProvider<Object>? imageProvider,
    int initialItem = 0,
    DownloadCallback? onDownload,
    AnimatorStyle animator = AnimatorStyle.fade,
  }) async {
    return await Navigator.of(context).push<T>(
      CustomerPageRoute<T>(
        ViewMediaPage(
          medias: medias,
          initialItem: initialItem,
          imageProvider: imageProvider,
          onDownload: onDownload,
        ),
        style: animator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ViewMedia(
      medias: medias,
      initialItem: initialItem,
      imageProvider: imageProvider,
      onDownload: onDownload,
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
