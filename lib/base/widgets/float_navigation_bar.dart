import 'package:flutter/material.dart';

/// 用法：
/// class FloatNavigationPage extends StatefulWidget {
//   @override
//   _FloatNavigationPageState createState() => _FloatNavigationPageState();
// }
//
// class _FloatNavigationPageState extends State<FloatNavigationPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0.0,
//         title: Text('Float Navigation'),
//         centerTitle: true,
//       ),
//       backgroundColor: Color(0xFFFF0035),
//       body: Center(child: Text('hello')),
//       bottomNavigationBar: FloatNavigationBar(),
//     );
//   }
// }
class FloatNavigationBar extends StatefulWidget {
  final int actionIndex; // 默认悬浮按钮的位置
  final double barHeight; // 正常显示的高度
  final Color? actionColor; // 选中的颜色
  final Color? inactionColor; // 未选中的颜色
  final List<IconData> icons; // 显示的图标
  final List<String>? title; // 显示的文本

  FloatNavigationBar(
    this.icons, {
    this.actionIndex = 0,
    this.barHeight = 48.0,
    this.actionColor = Colors.blue,
    this.inactionColor = Colors.grey,
    this.title,
  });

  @override
  _FloatNavigatorState createState() => _FloatNavigatorState();
}

class _FloatNavigatorState extends State<FloatNavigationBar> with SingleTickerProviderStateMixin {
  int _itemCount = 0; // item数量
  int _activeIndex = 0; // 显示为悬浮按钮的位置
  double _radiusPadding = 10.0;
  double _radius = 0; // 悬浮图标半径
  double _moveTween = 0.0; // 移动补间

  AnimationController? _animationController; // 动画控制器

  @override
  void initState() {
    _activeIndex = widget.actionIndex;
    _radius = widget.barHeight * 2 / 3;
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _itemCount = widget.icons.length;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      width: width,
      child: Stack(
        clipBehavior: Clip.none,
        children: [_activeNavigationItem(width), _inactiveNavigationItem()],
      ),
    );
  }

  // 浮动在底部导航栏的Item
  Widget _activeNavigationItem(double width) {
    double padding = _radiusPadding / 2;
    double itemWidth = width / _itemCount;

    // 顶部偏离的距离
    double top = getNavigationValue() <= 0.5
        ? (getNavigationValue() * widget.barHeight * padding) - _radius / 3 * 2
        : (1 - getNavigationValue()) * widget.barHeight * padding - _radius / 3 * 2;
    // 左边偏移的距离
    double left = _moveTween * itemWidth + (itemWidth - _radius) / 2 - padding;

    return Positioned(
      top: top,
      left: left,
      child: DecoratedBox(
        decoration: ShapeDecoration(shape: CircleBorder(), shadows: [
          BoxShadow(
            blurRadius: padding,
            offset: Offset(0, padding),
            spreadRadius: 0,
            color: Colors.black26,
          ),
        ]),
        child: CircleAvatar(
          radius: _radius - _radiusPadding, // 浮动图标和圆弧之间设置 padding 间隙
          backgroundColor: Colors.white,
          child: Icon(widget.icons[_activeIndex], color: widget.actionColor),
        ),
      ),
    );
  }

  // 未被选中的导航栏Item
  Widget _inactiveNavigationItem() {
    return CustomPaint(
      painter: ArcPainter(navCount: _itemCount, moveTween: _moveTween, padding: _radiusPadding),
      child: SizedBox(
        height: widget.barHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widget.icons
              .asMap()
              .map(
                (i, v) => MapEntry(i, GestureDetector(child: getItem(i, _activeIndex == i), onTap: () => _switchNavigationItem(i))),
              )
              .values
              .toList(),
        ),
      ),
    );
  }

  Widget getItem(int index, bool selected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(widget.icons[index], color: selected ? Colors.transparent : widget.inactionColor),
        Offstage(
          offstage: widget.title == null || _activeIndex == index,
          child: Text(widget.title?[index] ?? '', style: TextStyle(color: widget.inactionColor)),
        ),
      ],
    );
  }

  // 切换导航
  _switchNavigationItem(int newIndex) {
    double oldPosition = _activeIndex.toDouble();
    double newPosition = newIndex.toDouble();
    if (oldPosition != newPosition && _animationController?.status != AnimationStatus.forward) {
      _animationController?.reset();
      Animation<double>? animation =
          Tween(begin: oldPosition, end: newPosition).animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeInCubic));
      animation
        ..addListener(() => setState(() => _moveTween = animation.value))
        ..addStatusListener((AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            setState(() => _activeIndex = newIndex);
          }
        });
      _animationController?.forward();
    }
  }

  double getNavigationValue() => _animationController?.value ?? 0;

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}

/// 绘制圆弧背景
class ArcPainter extends CustomPainter {
  final int navCount; // 导航总数
  final double moveTween; // 移动补间
  final double padding; // 间隙
  ArcPainter({this.navCount = 0, this.moveTween = 0, this.padding = 0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = (Colors.white)
      ..style = PaintingStyle.stroke;

    double width = size.width; // 导航栏总宽度，即canvas宽度
    double height = size.height; // 导航栏总高度，即canvas高度
    double itemWidth = width / navCount; // 单个导航项宽度
    double arcRadius = height * 2 / 3; // 选中导航栏的圆弧半径
    double restSpace = (itemWidth - arcRadius * 2) / 2; // 单个导航项减去圆弧直径后单边剩余宽度

    Path path = Path()
      ..relativeLineTo(moveTween * itemWidth, 0)
      ..relativeCubicTo(restSpace + padding, 0, restSpace + padding / 2, arcRadius, itemWidth / 2, arcRadius) // 圆弧左半边
      ..relativeCubicTo(arcRadius, 0, arcRadius - padding, -arcRadius, restSpace + arcRadius, -arcRadius) // 圆弧右半边
      ..relativeLineTo(width - (moveTween + 1) * itemWidth, 0)
      ..relativeLineTo(0, height)
      ..relativeLineTo(-width, 0)
      ..relativeLineTo(0, -height)
      ..close();

    paint.style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
