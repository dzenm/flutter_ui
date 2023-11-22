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

  /// 自定义Popup箭头指向布局，如果为空不展示
  final Widget? arrow;

  /// Popup在target的方向，默认在正下方
  final PopupDirection? direction;

  /// Popup相对于Target的偏移量(正值x向右偏移，正值y向下偏移，负值x向左偏移，负值y向上偏移)，会影响Popup和箭头
  final Offset? offset;

  /// 箭头相对于Target的偏移量(正值x向右偏移，正值y向下偏移，负值x向左偏移，负值y向上偏移)，只影响箭头
  final Offset? arrowOffset;

  /// 如果超过范围是否使Popup在[direction]所在的方向等大
  final bool? isCollapsed;

  /// 如果超过范围是否使箭头的位置固定居中
  final bool? isPin;

  /// z轴的高度
  final double elevation;

  const CustomPopupWindow({
    super.key,
    required this.targetKey,
    required this.child,
    this.arrow,
    this.direction,
    this.offset,
    this.arrowOffset,
    this.isCollapsed,
    this.isPin,
    this.elevation = 0,
  });

  /// 创建一个自定义的PopupWindow
  static Future<T?> show<T>(
    context, {
    required GlobalKey targetKey,
    required Widget child,
    Widget? arrow,
    PopupDirection? direction,
    Offset? offset,
    Offset? arrowOffset,
    bool? isCollapsed,
    bool? isPin,
    double elevation = 0,
  }) async {
    return await Navigator.push(
      context,
      _CustomPopupRoute(
        child: CustomPopupWindow(
          targetKey: targetKey,
          arrow: arrow,
          direction: direction,
          offset: offset,
          arrowOffset: arrowOffset,
          isCollapsed: isCollapsed,
          isPin: isPin,
          elevation: elevation,
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
    Offset? arrowOffset,
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
      arrow: buildArrowView(direction ?? PopupDirection.bottom, color),
      arrowOffset: arrowOffset,
      isCollapsed: isCollapsed,
      isPin: isPin,
      elevation: elevation,
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

  /// Popup箭头布局
  static Widget buildArrowView(PopupDirection direction, Color color) {
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
class _PopupWindowState extends State<CustomPopupWindow> {
  final GlobalKey _popupKey = GlobalKey();
  final GlobalKey _arrowKey = GlobalKey();

  /// Popup初始位置，不能展示在屏幕内，所以设置为负数
  double _left = -2500, _top = -2500;

  /// Popup箭头方向的位置
  double _arrowLeft = -2500, _arrowTop = -2500;

  /// Popup的大小, 初始化必须为空
  double? _width, _height;

  /// 箭头的偏移量
  Offset _arrowOffset = const Offset(16, 0);
  bool _isCollapsed = false, _isPin = false;

  @override
  void initState() {
    super.initState();

    _isCollapsed = (widget.isCollapsed ?? _isCollapsed);
    _isPin = _isCollapsed && (widget.isPin ?? _isPin);
    _arrowOffset = widget.arrowOffset ?? _arrowOffset;
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculatorPopupPosition());
  }

  void _calculatorPopupPosition() {
    RenderBox? targetView = widget.targetKey.currentContext?.findRenderObject() as RenderBox?;
    RenderBox? popupView = _popupKey.currentContext?.findRenderObject() as RenderBox?;
    RenderBox? arrowView = _arrowKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetView == null || popupView == null) return;

    // TargetWidget的大小
    Size targetSize = targetView.size;
    // TargetWidget的坐标位置，相对于target位置的左上角
    Offset target = targetView.localToGlobal(Offset.zero);

    // PopupWindow的大小
    Size popupSize = popupView.size;
    _width = popupSize.width;
    _height = popupSize.height;

    // 箭头的大小
    Size arrowSize = arrowView?.size ?? const Size(0, 0);

    switch (widget.direction ?? PopupDirection.bottom) {
      // 在target的左边
      case PopupDirection.leftBottom:
        _fixBottomInHorizontal(target, targetSize, popupSize, arrowSize);
        _fixHorizontal(target, -popupSize.width, -arrowSize.width);
        break;
      case PopupDirection.left:
        _fixCenterInHorizontal(target, targetSize, popupSize, arrowSize);
        _fixHorizontal(target, -popupSize.width, -arrowSize.width);
        break;
      case PopupDirection.leftTop:
        _fixTopInHorizontal(target, targetSize, popupSize, arrowSize);
        _fixHorizontal(target, -popupSize.width, -arrowSize.width);
        break;

      // 在target的右边
      case PopupDirection.rightTop:
        _fixTopInHorizontal(target, targetSize, popupSize, arrowSize);
        _fixHorizontal(target, targetSize.width, arrowSize.width);
        break;
      case PopupDirection.right:
        _fixCenterInHorizontal(target, targetSize, popupSize, arrowSize);
        _fixHorizontal(target, targetSize.width, arrowSize.width);
        break;
      case PopupDirection.rightBottom:
        _fixBottomInHorizontal(target, targetSize, popupSize, arrowSize);
        _fixHorizontal(target, targetSize.width, arrowSize.width);
        break;

      // 在target的上边
      case PopupDirection.topLeft:
        _fixLeftInVertical(target, targetSize, popupSize, arrowSize);
        _fixVertical(target, -popupSize.height, -arrowSize.height);
        break;
      case PopupDirection.top:
        _fixCenterInVertical(target, targetSize, popupSize, arrowSize);
        _fixVertical(target, -popupSize.height, -arrowSize.height);
        break;
      case PopupDirection.topRight:
        _fixRightInVertical(target, targetSize, popupSize, arrowSize);
        _fixVertical(target, -popupSize.height, -arrowSize.height);
        break;

      // 在target的下边
      case PopupDirection.bottomRight:
        _fixRightInVertical(target, targetSize, popupSize, arrowSize);
        _fixVertical(target, targetSize.height, arrowSize.height);
        break;
      case PopupDirection.bottom:
        _fixCenterInVertical(target, targetSize, popupSize, arrowSize);
        _fixVertical(target, targetSize.height, arrowSize.height);
        break;
      case PopupDirection.bottomLeft:
        _fixLeftInVertical(target, targetSize, popupSize, arrowSize);
        _fixVertical(target, targetSize.height, arrowSize.height);
        break;
      default:
    }

    // 最后调整Popup展示的位置（保证在屏幕内，如果在屏幕外则进行调整）
    _fixPopupPosition(popupSize);
    setState(() {});
  }

  /// 调整水平方向的位置，正值为右边，负值为左边
  void _fixHorizontal(Offset target, double width, double arrowWidth) {
    Offset offset = widget.offset ?? const Offset(0, 0);
    double dx = target.dx + offset.dx;
    double offsetX = _arrowOffset.dy;
    // 正值为往下偏移，负值为往上偏移
    double internal = width > 0 ? offsetX : -offsetX;
    // width大于0时，加上的width是target的宽度，以及设定的箭头的偏移量，小于0时，加上的arrowWidth是箭头自身的宽度，以及设定的箭头的偏移量
    _arrowLeft = dx + (width > 0 ? width : arrowWidth) + internal;
    _left = dx + width + arrowWidth;
  }

  /// 调整位置在水平方向上边的时候
  void _fixTopInHorizontal(Offset target, Size targetSize, Size popupSize, Size arrowSize) {
    if (_isCollapsed) {
      // 使Target高度跟Popup高度一致时，需要调整Popup的高度
      _height = targetSize.height;
    }
    if (popupSize.height >= targetSize.height || _isPin) {
      // 使Target高度跟Popup高度一致/如果Popup高度比Target高度大，箭头位于Target中间
      _arrowTop = target.dy + targetSize.height / 2 - arrowSize.height / 2;
    } else {
      // 如果Popup高度比Target高度小，箭头根据设置的偏移量(从上往下)决定位置
      _arrowTop = target.dy + _arrowOffset.dx;
    }
    _top = target.dy;
  }

  /// 调整位置在水平方向中间的时候
  void _fixCenterInHorizontal(Offset target, Size targetSize, Size popupSize, Size arrowSize) {
    if (_isCollapsed) {
      _top = target.dy;
      _height = targetSize.height;
    } else {
      _top = target.dy + targetSize.height / 2 - popupSize.height / 2;
    }
    _arrowTop = target.dy + targetSize.height / 2 - arrowSize.height / 2;
  }

  /// 调整位置在水平方向下边的时候
  void _fixBottomInHorizontal(Offset target, Size targetSize, Size popupSize, Size arrowSize) {
    if (_isCollapsed) {
      // 使Target高度跟Popup高度一致时，需要调整Popup的高度
      _top = target.dy;
      _height = targetSize.height;
    } else {
      _top = target.dy + targetSize.height - popupSize.height;
    }
    if (popupSize.height >= targetSize.height || _isPin) {
      // 使Target高度跟Popup高度一致/如果Popup高度比Target高度大，箭头还是位于Target中间
      _arrowTop = target.dy + targetSize.height / 2 - arrowSize.height / 2;
    } else {
      // 如果Popup高度比Target高度小，箭头根据设置的偏移量(从下往上)决定位置
      _arrowTop = target.dy + targetSize.height - arrowSize.height - _arrowOffset.dx;
    }
  }

  /// 调整竖直方向的位置，正值为下边，负值为上边
  void _fixVertical(Offset target, double height, double arrowHeight) {
    Offset offset = widget.offset ?? const Offset(0, 0);
    // offset是包含箭头和Popup主体的偏移
    double dy = target.dy + offset.dy;
    // 0.5是为了消除箭头和Popup主体之间的间距
    double offsetY = _arrowOffset.dy + 0.5;
    // 正值为往下偏移，负值为往上偏移
    double internal = height > 0 ? offsetY : -offsetY;
    // height大于0时，加上的height是target的高度，以及设定的箭头的偏移量，小于0时，加上的arrowHeight是箭头自身的高度，以及设定的箭头的偏移量
    _arrowTop = dy + (height > 0 ? height : arrowHeight) + internal;
    _top = dy + height + arrowHeight;
  }

  /// 调整位置在竖直方向左边的时候
  void _fixLeftInVertical(Offset target, Size targetSize, Size popupSize, Size arrowSize) {
    if (_isCollapsed) {
      // 使Target宽度跟Popup宽度一致时，需要调整Popup的宽度
      _width = targetSize.width;
    }
    if (popupSize.width > targetSize.width || _isPin) {
      // 使Target宽度跟Popup宽度一致/如果Popup宽度比Target宽度大，箭头还是位于Target中间
      _arrowLeft = target.dx + targetSize.width / 2 - arrowSize.width / 2;
    } else {
      // 如果Popup宽度比Target宽度小，箭头根据设置的偏移量(从左往右)决定位置
      _arrowLeft = target.dx + _arrowOffset.dx;
    }
    _left = target.dx;
  }

  /// 调整位置在竖直方向中间的时候
  void _fixCenterInVertical(Offset target, Size targetSize, Size popupSize, Size arrowSize) {
    if (_isCollapsed) {
      _left = target.dx;
      _width = targetSize.width;
    } else {
      _left = target.dx + targetSize.width / 2 - popupSize.width / 2;
    }
    _arrowLeft = target.dx + targetSize.width / 2 - arrowSize.width / 2;
  }

  /// 调整位置在竖直方向右边的时候
  void _fixRightInVertical(Offset target, Size targetSize, Size popupSize, Size arrowSize) {
    if (_isCollapsed) {
      // 使Target宽度跟Popup宽度一致时，需要调整Popup的宽度
      _left = target.dx;
      _width = targetSize.width;
    } else {
      _left = target.dx + targetSize.width - popupSize.width;
    }
    if (popupSize.width > targetSize.width || _isPin) {
      // 使Target宽度跟Popup宽度一致/如果Popup宽度比Target宽度大，箭头还是位于Target中间
      _arrowLeft = target.dx + targetSize.width / 2 - arrowSize.width / 2;
    } else {
      // 如果Popup高度比Target高度小，箭头根据设置的偏移量(从右往左)决定位置
      _arrowLeft = target.dx + targetSize.width - arrowSize.width - _arrowOffset.dx;
    }
  }

  /// 调整Popup的位置，使Popup不会溢出屏幕
  void _fixPopupPosition(Size popupSize) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    if (_left < 0) {
      _left = 0;
    }
    if (_left + popupSize.width >= width) {
      _left = width - popupSize.width;
    }
    if (_top < 0) {
      _top = 0;
    }
    if (_top + popupSize.height >= height) {
      _top = height - popupSize.height;
    }
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
            left: _left,
            top: _top,
            child: GestureDetector(child: _buildCustomView()),
          ),
          Positioned(
            left: _arrowLeft,
            top: _arrowTop,
            child: _buildArrowView(),
          ),
        ]),
        onTap: () => Navigator.pop(context),
      ),
    );
  }

  /// 自定义的Popup Widget布局
  Widget _buildCustomView() {
    return Material(
      type: widget.elevation == 0 ? MaterialType.transparency : MaterialType.card,
      elevation: widget.elevation,
      child: SizedBox(
        key: _popupKey,
        width: _width,
        height: _height,
        child: widget.child,
      ),
    );
  }

  /// Popup Widget指向的箭头布局
  Widget _buildArrowView() {
    return Container(
      key: _arrowKey,
      child: widget.arrow,
    );
  }
}

/// 自定义的Popup跳转时的路由
class _CustomPopupRoute<T> extends PopupRoute<T> {
  final Duration _duration = const Duration(milliseconds: 100);
  Widget child;

  _CustomPopupRoute({required this.child});

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Duration get transitionDuration => _duration;
}

/// 绘制三角形
class _TrianglePainter extends CustomPainter {
  Color color; //填充颜色
  final Paint _paint = Paint(); //画笔
  final Path _path = Path(); //绘制路径
  PopupDirection direction;

  _TrianglePainter({
    this.color = Colors.grey,
    this.direction = PopupDirection.bottom,
  }) {
    _paint
      ..strokeWidth = 0.0 //线宽
      ..color = color
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    double height = size.height;
    final baseX = size.width * 0.5;
    final baseY = size.height * 0.5;
    if (direction == PopupDirection.left) {
      _path.moveTo(0, 0);
      _path.lineTo(0, height);
      _path.lineTo(baseY, baseY);
      canvas.drawPath(_path, _paint);
    } else if (direction == PopupDirection.top) {
      _path.moveTo(0, 0);
      _path.lineTo(width, 0);
      _path.lineTo(baseX, baseX);
      canvas.drawPath(_path, _paint);
    } else if (direction == PopupDirection.right) {
      _path.moveTo(width, 0);
      _path.lineTo(width, height);
      _path.lineTo(width - baseY, baseY);
      canvas.drawPath(_path, _paint);
    } else if (direction == PopupDirection.bottom) {
      _path.moveTo(0, height);
      _path.lineTo(width, height);
      _path.lineTo(baseX, height - baseX);
      canvas.drawPath(_path, _paint);
    }
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
