import 'package:flutter/material.dart';

///
/// Created by a0010 on 2022/6/16 16:42
///
class SlideVerifyView extends StatefulWidget {
  /// 背景色
  final Color backgroundColor;

  /// 滑动过的颜色
  final Color slideColor;

  /// 边框颜色
  final Color borderColor;

  final double height;
  final double width;

  final VoidCallback onChanged;

  const SlideVerifyView({
    Key? key,
    this.backgroundColor = Colors.blueGrey,
    this.slideColor = Colors.green,
    this.borderColor = Colors.grey,
    this.height = 44,
    this.width = 260,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SlideVerifyViewState();
}

class _SlideVerifyViewState extends State<SlideVerifyView> with TickerProviderStateMixin {
  double _height = 0, _width = 0;

  /// 滑块滑动的总距离
  double _sliderDistance = 0;

  /// 滑块的初始长度
  double _initial = 0.0;

  /// 滑动块宽度
  double _sliderWidth = 64;

  /// 是否允许拖动
  bool _enableSlide = true;

  AnimationController? _animationController;
  Animation? _curve;

  @override
  void initState() {
    super.initState();
    _width = widget.width;
    _height = widget.height;
    _initAnimation();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails details) {
        if (!_enableSlide) {
          return;
        }
        _initial = details.globalPosition.dx;
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!_enableSlide) {
          return;
        }
        _sliderDistance = details.globalPosition.dx - _initial;
        if (_sliderDistance < 0) {
          _sliderDistance = 0;
        }

        /// 当滑动到最右边时，通知验证成功，并禁止滑动
        if (_sliderDistance > _width - _sliderWidth) {
          _sliderDistance = _width - _sliderWidth;
          _enableSlide = false;
          widget.onChanged();
        }
        setState(() {});
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        /// 滑动松开时，如果未达到最右边，启动回弹动画
        if (_enableSlide) {
          _enableSlide = false;
          _animationController?.forward();
        }
      },
      child: Container(
        height: _height,
        width: _width,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          border: Border.all(color: widget.borderColor),

          /// 圆角实现
          borderRadius: BorderRadius.all(new Radius.circular(_height)),
        ),
        child: Stack(children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              height: _height - 2,

              /// 当slider滑动到距左边只有两三像素距离时，已滑动背景会有一点点渲染出边框范围，
              /// 因此当滑动距离小于1时，直接将宽度设置为0，解决滑动块返回左边时导致的绿色闪动，但如果是缓慢滑动到左边该问题仍没解决
              width: _sliderDistance < 1 ? 0 : _sliderDistance + _sliderWidth / 2,
              decoration: BoxDecoration(
                  color: widget.slideColor,

                  /// 圆角实现
                  borderRadius: BorderRadius.all(new Radius.circular(_width / 2))),
            ),
          ),
          Center(
            child: Text(
              '向右滑动解锁发言',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          Positioned(
            top: 0,

            /// 此处将sliderDistance距离往左偏2是解决当滑动块滑动到最右边时遮挡外部边框
            left: _sliderDistance > _sliderWidth ? _sliderDistance - 2 : _sliderDistance,
            child: Container(
              width: _sliderWidth,
              height: _height - 2,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: widget.borderColor),

                  /// 圆角实现
                  borderRadius: BorderRadius.all(new Radius.circular(_height))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 6),
                  Icon(Icons.verified_user_outlined, size: 24, color: widget.slideColor),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16, color: widget.slideColor),

                  /// 因为向右箭头有透明边距导致两个箭头间隔过大，因此将第二个箭头向左偏移，如果切图无边距则不用偏移
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }

  /// 回弹动画
  void _initAnimation() {
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _curve = CurvedAnimation(parent: _animationController!, curve: Curves.easeOut);
    _curve?.addListener(() {
      setState(() {
        _sliderDistance = _sliderDistance - _sliderDistance * _curve?.value;
        if (_sliderDistance <= 0) {
          _sliderDistance = 0;
        }
      });
    });
    _animationController?.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _enableSlide = true;
        _animationController?.reset();
      }
    });
  }
}
