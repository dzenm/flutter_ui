import 'dart:math';

import 'package:flutter/material.dart';

import 'tap_layout.dart';

typedef ItemTapCallback = void Function(int index);

///
/// Created by a0010 on 2022/11/25 13:51
///
/// PopupWindow, 在任意target的指定方向显示一个child
class CustomPopupWindow extends StatefulWidget {
  /// Popup相对于Target展示的target key
  final GlobalKey targetKey;

  /// 自定义Popup布局
  final Widget child;

  /// 弹窗的背景色
  final Color? color;

  /// 自定义Popup方向指示器布局，如果为空不展示
  final Widget? directChild;

  /// Popup在target的方向，默认在正下方
  final PopupDirection direction;

  /// Popup相对于Target的偏移量(x为横向方向偏移，x为竖向方向偏移)，会影响Popup和方向指示器
  final Offset offset;

  /// 方向指示器相对于Popup的偏移量(x为横向方向偏移，x为竖向方向偏移)，只影响方向指示器
  final Offset directOffset;

  /// Popup是否可以溢出屏幕外显示
  final bool isOverflow;

  /// 超过范围是否使Popup在[direction]所在的方向等大
  final bool isCollapsed;

  /// 方向指示器是否相对于Target固定在中间，如果为true，那么 [directOffset] 的设置将失效
  final bool isPin;

  /// z轴的高度
  final double elevation;

  /// Popup的圆角
  final BorderRadiusGeometry? borderRadius;

  const CustomPopupWindow({
    super.key,
    required this.targetKey,
    required this.child,
    this.color,
    this.directChild,
    PopupDirection? direction,
    Offset? offset,
    Offset? directOffset,
    bool? isOverflow,
    bool? isCollapsed,
    bool? isPin,
    this.elevation = 0,
    this.borderRadius,
  })  : direction = direction ?? PopupDirection.bottom,
        offset = offset ?? const Offset(0, 0),
        directOffset = directOffset ?? const Offset(16, 16),
        isOverflow = isOverflow ?? false,
        isCollapsed = isCollapsed ?? false,
        isPin = isPin ?? false;

  /// 创建一个自定义的PopupWindow
  static Future<T?> show<T>(
      context, {
        required GlobalKey targetKey,
        required Widget child,
        RouteTransitionsBuilder? builder,
        Color? color,
        Widget? directChild,
        PopupDirection? direction,
        Offset? offset,
        Offset? directOffset,
        bool? isCollapsed,
        bool? isPin,
        double elevation = 0,
        BorderRadiusGeometry? borderRadius,
      }) async {
    return await Navigator.push(
      context,
      _CustomPopupRoute(
        builder: builder,
        child: CustomPopupWindow(
          targetKey: targetKey,
          color: color ?? Colors.white,
          directChild: directChild,
          direction: direction,
          offset: offset,
          directOffset: directOffset,
          isCollapsed: isCollapsed,
          isPin: isPin,
          elevation: elevation,
          borderRadius: borderRadius,
          child: child,
        ),
      ),
    );
  }

  /// SizedBox(
  ///   key: _targetKey,
  ///   width: 120,
  ///   height: 200,
  ///   child: MaterialButton(
  ///     onPressed: () {
  ///       CustomPopupWindow.showList(
  ///         context,
  ///         targetKey: targetKey,
  ///         titles: ['全选', '复制', '粘贴', '测试'],
  ///         direction: PopupDirection.rightBottom,
  ///         onItemTap: (index) {
  ///           CommonDialog.showToast('第${index + 1}个Item');
  ///         },
  ///       );
  ///     },
  ///     color: Colors.amberAccent,
  ///     child: Text(
  ///       "Custom",
  ///       style: TextStyle(color: Colors.white),
  ///     ),
  ///   ),
  /// )
  /// 创建一个列表的PopupWindow
  static Future<T?> showList<T>(
      context, {
        required GlobalKey targetKey,
        PopupDirection? direction,
        Offset? offset,
        Offset? directOffset,
        bool? isCollapsed,
        bool? isPin,
        required List<String> titles,
        EdgeInsetsGeometry? padding,
        double radius = 8,
        Color color = const Color(0xff4c4c4c),
        Color? textColor,
        ItemTapCallback? onItemTap,
        double elevation = 0,
      }) async {
    return await show(
      context,
      targetKey: targetKey,
      direction: direction ?? PopupDirection.bottom,
      offset: offset,
      directOffset: directOffset,
      directChild: buildDirectView(direction ?? PopupDirection.bottom, color),
      isCollapsed: isCollapsed,
      isPin: isPin,
      elevation: elevation,
      borderRadius: BorderRadius.circular(radius),
      child: _buildContentView(
        color: color,
        radius: radius,
        child: _buildListView(
          titles,
          padding: padding,
          color: textColor,
          onTap: (index) {
            Navigator.pop(context);
            if (onItemTap != null) onItemTap(index);
          },
        ),
      ),
    );
  }

  /// Popup最外层布局
  static Widget _buildContentView({required Widget child, Color? color, double? radius}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 0)),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 10.0,
            spreadRadius: 0.0,
            color: Color(0x0D000000),
          ),
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 4.0,
            spreadRadius: 0.0,
            color: Color(0x14000000),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: child,
    );
  }

  /// 创建一个Popup的列表
  static Widget _buildListView(List<String> titles, {Color? color, EdgeInsetsGeometry? padding, required ItemTapCallback onTap}) {
    List<Widget> widgets = [];
    for (int i = 0; i < titles.length; i++) {
      widgets.add(TapLayout(
        padding: padding ?? const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
        child: Text(titles[i], style: TextStyle(color: color ?? Colors.white)),
        onTap: () => onTap(i),
      ));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widgets,
    );
  }

  /// Popup方向指示器布局
  static Widget buildDirectView(PopupDirection direction, Color color) {
    bool isTop = [PopupDirection.topLeft, PopupDirection.top, PopupDirection.topRight].contains(direction);
    bool isBottom = [PopupDirection.bottomLeft, PopupDirection.bottom, PopupDirection.bottomRight].contains(direction);
    bool isLeft = [PopupDirection.leftTop, PopupDirection.left, PopupDirection.leftBottom].contains(direction);
    bool isVertical = isTop || isBottom;
    PopupDirection myDirection = isTop
        ? PopupDirection.top
        : isBottom
        ? PopupDirection.bottom
        : isLeft
        ? PopupDirection.left
        : PopupDirection.right;
    return SizedBox(
      width: isVertical ? 12 : 6,
      height: isVertical ? 6 : 12,
      child: CustomPaint(
        painter: _TrianglePainter(
          color: color,
          direction: myDirection,
        ),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _PopupWindowState();
}

/// PopupWindow的布局
class _PopupWindowState extends State<CustomPopupWindow> with _CalculatePopupPositionMixin {
  @override
  void initState() {
    super.initState();
    initPopup();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculatorPopupPosition());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        child: Stack(children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.transparent,
          ),
          Positioned(
            left: _offset.dx,
            top: _offset.dy,
            child: GestureDetector(child: _buildCustomView()),
          ),
          Positioned(
            left: _directOffset.dx,
            top: _directOffset.dy,
            child: _buildDirectView(),
          ),
        ]),
        onTap: () => Navigator.pop(context),
      ),
    );
  }

  /// 自定义的Popup Widget布局
  Widget _buildCustomView() {
    return Material(
      color: widget.color,
      type: widget.elevation == 0 ? MaterialType.transparency : MaterialType.card,
      borderRadius: widget.borderRadius,
      elevation: widget.elevation,
      child: SizedBox(
        key: _popupKey,
        width: _size?.width,
        height: _size?.height,
        child: widget.child,
      ),
    );
  }

  /// Popup Widget指向的方向指示器布局
  Widget _buildDirectView() {
    return Container(
      key: _directKey,
      child: widget.directChild,
    );
  }
}

/// 计算Popup位置
mixin _CalculatePopupPositionMixin on State<CustomPopupWindow> {
  final GlobalKey _popupKey = GlobalKey();
  final GlobalKey _directKey = GlobalKey();

  /// Popup初始位置，不能展示在屏幕内，所以设置为负数
  Offset _offset = const Offset(-10000, -10000);

  /// Popup方向指示器的位置
  Offset _directOffset = const Offset(-10000, -10000);

  /// Popup的大小, 初始化必须为空
  Size? _size;

  bool _isCollapsed = false, _isPinDirect = false;

  void initPopup() {
    _isCollapsed = widget.isCollapsed;
    _isPinDirect = widget.isPin;
  }

  /// 计算Popup的位置
  void _calculatorPopupPosition() {
    RenderBox? targetView = widget.targetKey.currentContext?.findRenderObject() as RenderBox?;
    RenderBox? popupView = _popupKey.currentContext?.findRenderObject() as RenderBox?;
    RenderBox? directView = _directKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetView == null || popupView == null) return;

    // TargetWidget的大小
    Size targetSize = targetView.size;
    // TargetWidget的坐标位置，相对于target位置的左上角
    Offset target = targetView.localToGlobal(Offset.zero);

    // PopupWindow的大小
    _size = popupView.size;

    // 方向指示器的大小
    Size directSize = directView?.size ?? const Size(0, 0);

    // 先调整大小，再调整方向
    _size = _adjustPopupSize(isVertical, targetSize, _size!);
    // 调整所在方向的位置
    _fixPosition(targetSize, _size!, directSize, target);
    // 最后调整Popup展示的位置（保证在屏幕内，如果在屏幕外则进行调整）
    _fixPopupPosition(_size!);
    setState(() {});
  }

  /// 调整Popup在 [direction] 方向的大小
  Size _adjustPopupSize(bool isVertical, Size targetSize, Size popupSize) {
    if (!_isCollapsed) return popupSize;
    if (isVertical) {
      double width = min(targetSize.width, popupSize.width);
      return Size(width, popupSize.height);
    }
    double height = min(targetSize.height, popupSize.height);
    return Size(popupSize.width, height);
  }

  /// 是否在竖直方向
  bool get isVertical => [
    PopupDirection.topLeft,
    PopupDirection.top,
    PopupDirection.topRight,
    PopupDirection.bottomLeft,
    PopupDirection.bottom,
    PopupDirection.bottomRight,
  ].contains(widget.direction);

  /// 调整位置
  void _fixPosition(Size targetSize, Size popupSize, Size directSize, Offset target) {
    double dx = target.dx + widget.offset.dx;
    double dy = target.dy + widget.offset.dy;
    double internal = 0.2; // 为了消除Popup和direct的间隙，调整direct向Popup移动的间距

    Offset offset = widget.directOffset;
    double x = 0, y = 0, dirX = offset.dx, dirY = offset.dy; // 默认的位置

    double directLeft = -(directSize.width + internal);
    double directRight = targetSize.width + internal;
    double directTop = -(directSize.height + internal);
    double directBottom = targetSize.height + internal;

    double directHorizontalCenter = targetSize.height / 2 - directSize.height / 2;
    double directVerticalCenter = targetSize.width / 2 - directSize.width / 2;
    double directHorizontalTop;
    if (_isPinDirect) {
      directHorizontalTop = directHorizontalCenter;
    } else {
      directHorizontalTop = targetSize.height - dirY - directSize.height;
    }
    double directVerticalRight;
    if (_isPinDirect) {
      directVerticalRight = directVerticalCenter;
    } else {
      directVerticalRight = targetSize.width - dirX - directSize.width;
    }

    double popupLeft = -(popupSize.width + directSize.width);
    double popupRight = targetSize.width + directSize.width;
    double popupTop = -(directSize.height + popupSize.height);
    double popupBottom = targetSize.height + directSize.height;

    double popupHorizontalCenter = targetSize.width / 2 - popupSize.width / 2;
    double popupVerticalCenter = targetSize.height / 2 - popupSize.height / 2;
    double popupHorizontalTop = targetSize.height - popupSize.height;
    double popupVerticalRight = targetSize.width - popupSize.width;

    switch (widget.direction) {
    // 在target的左边
      case PopupDirection.leftBottom:
        dirX = directLeft;
        if (_isPinDirect) dirY = directHorizontalCenter;
        x = popupLeft;
        break;
      case PopupDirection.left:
        dirX = directLeft;
        dirY = directHorizontalCenter;
        x = popupLeft;
        y = popupVerticalCenter;
        break;
      case PopupDirection.leftTop:
        dirX = directLeft;
        dirY = directHorizontalTop;
        x = popupLeft;
        y = popupHorizontalTop;
        break;

    // 在target的右边
      case PopupDirection.rightTop:
        dirX = directRight;
        dirY = directHorizontalTop;
        x = popupRight;
        y = popupHorizontalTop;
        break;
      case PopupDirection.right:
        dirX = directRight;
        dirY = directHorizontalCenter;
        x = popupRight;
        y = popupVerticalCenter;
        break;
      case PopupDirection.rightBottom:
        dirX = directRight;
        if (_isPinDirect) dirY = directHorizontalCenter;
        x = popupRight;
        break;

    // 在target的上边
      case PopupDirection.topLeft:
        if (_isPinDirect) dirX = directVerticalCenter;
        dirY = directTop;
        y = popupTop;
        break;
      case PopupDirection.top:
        dirX = directVerticalCenter;
        dirY = directTop;
        x = popupHorizontalCenter;
        y = popupTop;
        break;
      case PopupDirection.topRight:
        dirX = directVerticalRight;
        dirY = directTop;
        x = popupVerticalRight;
        y = popupTop;
        break;

    // 在target的下边
      case PopupDirection.bottomRight:
        dirX = directVerticalRight;
        dirY = directBottom;
        x = popupVerticalRight;
        y = popupBottom;
        break;
      case PopupDirection.bottom:
        dirX = directVerticalCenter;
        dirY = directBottom;
        x = popupHorizontalCenter;
        y = popupBottom;
        break;
      case PopupDirection.bottomLeft:
        if (_isPinDirect) dirX = directVerticalCenter;
        dirY = directBottom;
        y = popupBottom;
        break;
    }

    _offset = Offset(dx + x, dy + y);
    _directOffset = Offset(dx + dirX, dy + dirY);
  }

  /// 调整Popup的位置，使Popup不会溢出屏幕
  void _fixPopupPosition(Size popupSize) {
    if (!widget.isOverflow) return;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double dx = _offset.dx, dy = _offset.dy;
    if (_offset.dx < 0) {
      dx = 0;
    } else if (_offset.dx + popupSize.width >= width) {
      dx = width - popupSize.width;
    }
    if (_offset.dy < 0) {
      dy = 0;
    } else if (_offset.dy + popupSize.height >= height) {
      dy = height - popupSize.height;
    }
    _offset = Offset(dx, dy);
  }
}

/// 自定义的Popup跳转时的路由
class _CustomPopupRoute<T> extends PopupRoute<T> {
  final Duration _duration = const Duration(milliseconds: 100);
  final Widget child;
  final RouteTransitionsBuilder? builder;

  _CustomPopupRoute({required this.child, this.builder});

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder == null ? child : builder!(context, animation, secondaryAnimation, child);
  }

  @override
  Duration get transitionDuration => _duration;
}

/// 绘制三角形
class _TrianglePainter extends CustomPainter {
  final Color color; //填充颜色
  final PopupDirection direction;

  final Paint _paint = Paint(); //画笔
  final Path _path = Path(); //绘制路径

  _TrianglePainter({required this.color, required this.direction}) {
    _paint
      ..strokeWidth = 0.0 //线宽
      ..color = color
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制的范围
    double width = size.width;
    double height = size.height;

    // 绘制三角形的基点，即宽/高的中点
    final baseX = width * 0.5;
    final baseY = height * 0.5;
    // 绘制不同方向的三角形（找到矩形内的三个点绘制正三角形），方向指示器和Popup方向是相反的方向
    if (direction == PopupDirection.left) {
      _path.moveTo(0, 0);
      _path.lineTo(0, height);
      _path.lineTo(baseY, baseY);
    } else if (direction == PopupDirection.top) {
      _path.moveTo(0, 0);
      _path.lineTo(width, 0);
      _path.lineTo(baseX, baseX);
    } else if (direction == PopupDirection.right) {
      _path.moveTo(width, 0);
      _path.lineTo(width, height);
      _path.lineTo(width - baseY, baseY);
    } else if (direction == PopupDirection.bottom) {
      _path.moveTo(0, height);
      _path.lineTo(width, height);
      _path.lineTo(baseX, height - baseX);
    }
    canvas.drawPath(_path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

/// PopupWindow显示的方向
enum PopupDirection {
  leftBottom,
  left,
  leftTop,
  topLeft,
  top,
  topRight,
  rightTop,
  right,
  rightBottom,
  bottomRight,
  bottom,
  bottomLeft,
}