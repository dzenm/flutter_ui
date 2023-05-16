import 'dart:math';

import 'package:flutter/material.dart';

import '../log/log.dart';
import '../res/assets.dart';
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

  const CustomPopupWindow({
    super.key,
    required this.targetKey,
    required this.child,
    this.arrow,
    this.direction,
    this.offset,
    this.arrowOffset,
    this.isCollapsed,
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
  }) async {
    return await Navigator.push(
      context,
      _CustomPopupRoute(
        child: CustomPopupWindow(
          targetKey: targetKey,
          child: child,
          arrow: arrow,
          direction: direction,
          offset: offset,
          arrowOffset: arrowOffset,
          isCollapsed: isCollapsed,
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
    bool? isCollapsed,
    required List<String> titles,
    EdgeInsetsGeometry? padding,
    double radius = 8,
    Color? color,
    Color? textColor,
    ItemTapCallback? onItemTap,
  }) async {
    return await show(
      context,
      targetKey: targetKey,
      direction: direction ?? PopupDirection.bottom,
      offset: offset,
      isCollapsed: isCollapsed,
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
        color: color ?? Colors.black38,
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 0)),
        boxShadow: [
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
      padding: EdgeInsets.symmetric(vertical: 8),
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
  static Widget buildArrowView(PopupDirection direction, Color? color) {
    bool isTop = [PopupDirection.topLeft, PopupDirection.top, PopupDirection.topRight].contains(direction);
    bool isBottom = [PopupDirection.bottomLeft, PopupDirection.bottom, PopupDirection.bottomRight].contains(direction);
    bool isLeft = [PopupDirection.leftTop, PopupDirection.left, PopupDirection.leftBottom].contains(direction);
    double angle = isBottom
        ? 0
        : isTop
            ? pi
            : isLeft
                ? pi / 2
                : -pi / 2;
    return Transform.rotate(
      angle: angle,
      child: Image.asset(
        Assets.image('ic_triangle.png'),
        width: 12.0,
        height: 6.0,
        color: color ?? Colors.black38,
        scale: 1.5,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _PopupWindowState();
}

class _PopupWindowState extends State<CustomPopupWindow> {
  GlobalKey _popupKey = GlobalKey();
  GlobalKey _arrowKey = GlobalKey();

  /// Popup初始位置，不能展示在屏幕内，所以设置为负数
  double _left = -100, _top = -100;

  /// Popup箭头方向的位置
  double _arrowLeft = -100, _arrowTop = -100;

  /// Popup的大小, 初始化必须为空
  double? _width, _height;

  /// 箭头的偏移量
  Offset _arrowOffset = Offset(16, 2);

  @override
  void initState() {
    super.initState();

    _arrowOffset = widget.arrowOffset ?? Offset(16, 2);
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculatorPopupPosition());
  }

  void _calculatorPopupPosition() {
    RenderBox? targetView = widget.targetKey.currentContext?.findRenderObject() as RenderBox?;
    RenderBox? popupView = _popupKey.currentContext?.findRenderObject() as RenderBox?;
    RenderBox? arrowView = _arrowKey.currentContext?.findRenderObject() as RenderBox?;
    if (targetView == null || popupView == null) return;
    bool collapsed = widget.isCollapsed ?? false;

    // TargetWidget的大小
    Size targetSize = targetView.size;
    // TargetWidget的坐标位置，相对于target位置的左上角
    Offset target = targetView.localToGlobal(Offset.zero);

    // PopupWindow的大小
    Size popupSize = popupView.size;
    _width = popupSize.width;
    _height = popupSize.height;

    // 箭头的大小
    Size arrowSize = arrowView?.size ?? Size(0, 0);

    switch (widget.direction ?? PopupDirection.bottom) {
      // 在target的左边
      case PopupDirection.leftBottom:
        _fixBottomInHorizontal(collapsed, target, targetSize, popupSize, arrowSize);
        _fixHorizontal(target, -popupSize.width, -arrowSize.width);
        break;
      case PopupDirection.left:
        _fixCenterInHorizontal(collapsed, target, targetSize, popupSize, arrowSize);
        _fixHorizontal(target, -popupSize.width, -arrowSize.width);
        break;
      case PopupDirection.leftTop:
        _fixTopInHorizontal(collapsed, target, targetSize, popupSize, arrowSize);
        _fixHorizontal(target, -popupSize.width, -arrowSize.width);
        break;

      // 在target的右边
      case PopupDirection.rightTop:
        _fixTopInHorizontal(collapsed, target, targetSize, popupSize, arrowSize);
        _fixHorizontal(target, targetSize.width, arrowSize.width);
        break;
      case PopupDirection.right:
        _fixCenterInHorizontal(collapsed, target, targetSize, popupSize, arrowSize);
        _fixHorizontal(target, targetSize.width, arrowSize.width);
        break;
      case PopupDirection.rightBottom:
        _fixBottomInHorizontal(collapsed, target, targetSize, popupSize, arrowSize);
        _fixHorizontal(target, targetSize.width, arrowSize.width);
        break;

      // 在target的上边
      case PopupDirection.topLeft:
        _fixLeftInVertical(collapsed, target, targetSize, popupSize, arrowSize);
        _fixVertical(target, -popupSize.height, -arrowSize.height);
        break;
      case PopupDirection.top:
        _fixCenterInVertical(collapsed, target, targetSize, popupSize, arrowSize);
        _fixVertical(target, -popupSize.height, -arrowSize.height);
        break;
      case PopupDirection.topRight:
        _fixRightInVertical(collapsed, target, targetSize, popupSize, arrowSize);
        _fixVertical(target, -popupSize.height, -arrowSize.height);
        break;

      // 在target的下边
      case PopupDirection.bottomRight:
        _fixRightInVertical(collapsed, target, targetSize, popupSize, arrowSize);
        _fixVertical(target, targetSize.height, arrowSize.height);
        break;
      case PopupDirection.bottom:
        _fixCenterInVertical(collapsed, target, targetSize, popupSize, arrowSize);
        _fixVertical(target, targetSize.height, arrowSize.height);
        break;
      case PopupDirection.bottomLeft:
        _fixLeftInVertical(collapsed, target, targetSize, popupSize, arrowSize);
        _fixVertical(target, targetSize.height, arrowSize.height);
        break;
      default:
    }

    Log.d('Popup初始化：target=${target.toString()}, targetSize=${targetSize.toString()}, popupSize=${popupSize.toString()},left=$_left, top=$_top');
    // 最后调整Popup展示的位置（保证在屏幕内，如果在屏幕外则进行调整）
    _fixPopupPosition(popupSize);
    setState(() {});
  }

  /// 调整水平方向的位置，正值为右边，负值为左边
  void _fixHorizontal(Offset target, double width, double arrowWidth) {
    Offset offset = widget.offset ?? Offset(0, 0);
    double dx = target.dx + offset.dx + (width > 0 ? _arrowOffset.dy : -_arrowOffset.dy);
    _arrowLeft = dx + (width > 0 ? width : arrowWidth);
    _left = dx + width + arrowWidth;
  }

  /// 调整位置在水平方向上边的时候
  void _fixTopInHorizontal(bool collapsed, Offset target, Size targetSize, Size popupSize, Size arrowSize) {
    if (collapsed) {
      _height = targetSize.height;
      _arrowTop = target.dy + targetSize.height / 2 - arrowSize.height / 2;
    } else {
      _arrowTop = target.dy + _arrowOffset.dx;
    }
    _top = target.dy;
  }

  /// 调整位置在水平方向中间的时候
  void _fixCenterInHorizontal(bool collapsed, Offset target, Size targetSize, Size popupSize, Size arrowSize) {
    if (collapsed) {
      _top = target.dy;
      _height = targetSize.height;
    } else {
      _top = target.dy + targetSize.height / 2 - popupSize.height / 2;
    }
    _arrowTop = target.dy + targetSize.height / 2 - arrowSize.height / 2;
  }

  /// 调整位置在水平方向下边的时候
  void _fixBottomInHorizontal(bool collapsed, Offset target, Size targetSize, Size popupSize, Size arrowSize) {
    if (collapsed) {
      _top = target.dy;
      _height = targetSize.height;
      _arrowTop = target.dy + targetSize.height / 2 - arrowSize.height / 2;
    } else {
      _top = target.dy + targetSize.height - popupSize.height;
      _arrowTop = target.dy + targetSize.height - arrowSize.height - _arrowOffset.dx;
    }
  }

  /// 调整竖直方向的位置，正值为下边，负值为上边
  void _fixVertical(Offset target, double height, double arrowHeight) {
    Offset offset = widget.offset ?? Offset(0, 0);
    double dy = target.dy + offset.dy + (height > 0 ? _arrowOffset.dy : -_arrowOffset.dy);
    _arrowTop = dy + (height > 0 ? height : arrowHeight);
    _top = dy + height + arrowHeight;
  }

  /// 调整位置在竖直方向左边的时候
  void _fixLeftInVertical(bool collapsed, Offset target, Size targetSize, Size popupSize, Size arrowSize) {
    if (collapsed) {
      _width = targetSize.width;
      _arrowLeft = target.dx + targetSize.width / 2 - arrowSize.width / 2;
    } else {
      _arrowLeft = target.dx + _arrowOffset.dx;
    }
    _left = target.dx;
  }

  /// 调整位置在竖直方向中间的时候
  void _fixCenterInVertical(bool collapsed, Offset target, Size targetSize, Size popupSize, Size arrowSize) {
    if (collapsed) {
      _left = target.dx;
      _width = targetSize.width;
    } else {
      _left = target.dx + targetSize.width / 2 - popupSize.width / 2;
    }
    _arrowLeft = target.dx + targetSize.width / 2 - arrowSize.width / 2;
  }

  /// 调整位置在竖直方向右边的时候
  void _fixRightInVertical(bool collapsed, Offset target, Size targetSize, Size popupSize, Size arrowSize) {
    if (collapsed) {
      _left = target.dx;
      _width = targetSize.width;
      _arrowLeft = target.dx + targetSize.width / 2 - arrowSize.width / 2;
    } else {
      _left = target.dx + targetSize.width - popupSize.width;
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
    return Container(
      key: _popupKey,
      width: _width,
      height: _height,
      child: widget.child,
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
