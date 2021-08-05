import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:photo_view/photo_view.dart';

void showPreviewPhotoPage(BuildContext context, List<String> url) {
  Navigator.of(context).push(CustomerPageRoute(PhotoPreviewPage(url), style: AnimatorStyle.fade));
}

/// 图片预览页面
class PhotoPreviewPage extends StatefulWidget {
  final List<String> url;

  PhotoPreviewPage(
    this.url,
  );

  @override
  State<StatefulWidget> createState() => _PhotoPreviewPageState();
}

class _PhotoPreviewPageState extends State<PhotoPreviewPage> {
  List<String> _list = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _list.addAll(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TapLayout(
        onTap: () => Navigator.pop(context),
        onLongPress: () => {},
        child: Stack(alignment: Alignment.center, children: [
          _buildPageView(),
          _buildIndicator(),
        ]),
      ),
    );
  }

  /// 创建PageView
  Widget _buildPageView() {
    return PageView(
      scrollDirection: Axis.horizontal,
      reverse: false,
      controller: PageController(
        initialPage: 0, //初始化第一次默认的位置
        viewportFraction: 1, //占屏幕多少，1为占满整个屏幕
        keepPage: true, //是否保存当前Page的状态，如果保存，下次进入对应保存的page，如果为false。下次总是从initialPage开始。
      ),
      physics: BouncingScrollPhysics(),
      // 是否具有回弹效果
      pageSnapping: true,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      children: _list.map((url) {
        return PhotoView(
          imageProvider: _isNetworkImage(url) ? AssetImage(url) : AssetImage(url),
          maxScale: 2.0,
          minScale: 0.0,
        );
      }).toList(),
    );
  }

  /// 创建指示器
  Widget _buildIndicator() {
    return Positioned(
      bottom: 80,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Offstage(
          offstage: _list.length <= 1,
          child: Text(
            '${_currentIndex + 1}/${_list.length}',
            style: TextStyle(color: Colors.white),
          ),
        )
      ]),
    );
  }

  /// 是否是网络图片
  bool _isNetworkImage(String url) {
    return url.startsWith('https://') || url.startsWith('http://');
  }
}

/// 自定义动画样式
class CustomerPageRoute extends PageRouteBuilder {
  final Widget widget;
  final AnimatorStyle style;

  CustomerPageRoute(
    this.widget, {
    this.style = AnimatorStyle.fade,
  }) : super(
          transitionDuration: Duration(milliseconds: 250),
          reverseTransitionDuration: Duration(milliseconds: 250),
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
                scale: Tween(begin: 0.0, end: 1.0) //设置缩放比例
                    .animate(CurvedAnimation(parent: animation, curve: Curves.linear)),
                child: child,
              );
            } else if (style == AnimatorStyle.translate) {
              //左右滑动动画效果
              return SlideTransition(
                position: Tween(begin: Offset(1.0, 0.0), end: Offset(0.0, 0.0)) //设置滑动起点和终点
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
