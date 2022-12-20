import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum PopupDirection { leftTop, top, rightTop, leftBottom, bottom, rightBottom, topLeft, left, bottomLeft, topRight, right, bottomRight }

typedef BoolCallback = bool Function();

double get _screenWidth => MediaQueryData.fromWindow(window).size.width;

double get _screenHeight => MediaQueryData.fromWindow(window).size.height;

/// 显示弹出窗口所在的widget
class PopupView extends StatelessWidget {
  final Widget child;
  final WidgetBuilder? popupDialogBuilder;
  final double? width;
  final double? height;
  final double elevation;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxConstraints? boxConstraints;
  final Color color;
  final List<BoxShadow>? boxShadow;
  final double radius;
  final Color barrierColor;
  final BoolCallback? onTap;
  final GestureLongPressCallback? onLongPress;
  final Duration transitionDuration;
  final PopupDirection direction;

  PopupView({
    Key? key,
    required this.child,
    this.popupDialogBuilder,
    this.width,
    this.height,
    this.elevation = 0.0,
    this.padding,
    this.margin,
    BoxConstraints? boxConstraints,
    this.color = Colors.white,
    this.boxShadow,
    this.radius = 8.0,
    this.barrierColor = Colors.black54,
    this.onTap,
    this.onLongPress,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.direction = PopupDirection.bottom,
  })  : assert(popupDialogBuilder != null),
        boxConstraints = (width != null || height != null) ? boxConstraints?.tighten(width: width, height: height) ?? BoxConstraints.tightFor(width: width, height: height) : boxConstraints,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      behavior: HitTestBehavior.translucent,
      onLongPress: () {
        if (onLongPress == null) {
          if (onTap != null) {
            _showPopupDialog(context);
          }
        } else {
          onLongPress!();
        }
      },
      onTap: () {
        if (onTap == null) {
          _showPopupDialog(context);
        } else {
          onTap!();
        }
      },
    );
  }

  void _showPopupDialog(BuildContext context) {
    Offset offset = _getWidgetLocalToGlobal(context);
    Rect bounds = _getWidgetBounds(context);
    Widget body;
    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        return Builder(builder: (BuildContext context) {
          return Container();
        });
      },
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierColor,
      transitionDuration: transitionDuration,
      transitionBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        body = popupDialogBuilder!(context);
        return Container(
          margin: margin,
          padding: padding,
          child: FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: PopupDialog(
              child: body,
              doubleAnimation: animation,
              attachRect: Rect.fromLTWH(offset.dx, offset.dy, bounds.width, bounds.height),
              constraints: boxConstraints,
              color: color,
              boxShadow: boxShadow,
              radius: radius,
              direction: direction,
            ),
          ),
        );
      },
    );
  }

  ///get Widget Bounds (width, height, left, top, right, bottom and so on).Widgets must be rendered completely.
  Rect _getWidgetBounds(BuildContext context) {
    RenderBox? box = context.findRenderObject() as RenderBox?;
    return (box != null) ? box.semanticBounds : Rect.zero;
  }

  ///Get the coordinates of the widget on the screen.Widgets must be rendered completely.
  Offset _getWidgetLocalToGlobal(BuildContext context) {
    RenderBox? box = context.findRenderObject() as RenderBox?;
    return box == null ? Offset.zero : box.localToGlobal(Offset.zero);
  }
}

/// 弹出窗口
class PopupDialog extends StatefulWidget {
  final Widget child;
  final Animation<double> doubleAnimation;
  final Rect attachRect;
  final BoxConstraints? constraints;
  final Color color;
  final List<BoxShadow>? boxShadow;
  final double radius;
  final PopupDirection direction;

  const PopupDialog({
    Key? key,
    required this.child,
    required this.doubleAnimation,
    required this.attachRect,
    required this.constraints,
    required this.color,
    required this.boxShadow,
    required this.radius,
    required this.direction,
  }) : super(key: key);

  BoxConstraints _getConstraints() {
    // 设置显示的最大范围
    BoxConstraints temp = BoxConstraints(maxHeight: _screenHeight * 2 / 3, maxWidth: 150.0);
    if (constraints != null) {
      BoxConstraints boxConstraints = constraints!;
      temp = temp.copyWith(
        minWidth: boxConstraints.minWidth.isFinite ? boxConstraints.minWidth : null,
        minHeight: boxConstraints.minHeight.isFinite ? boxConstraints.minHeight : null,
        maxWidth: boxConstraints.maxWidth.isFinite ? boxConstraints.maxWidth : null,
        maxHeight: boxConstraints.maxHeight.isFinite ? boxConstraints.maxHeight : null,
      );
    }
    return temp.copyWith(maxHeight: temp.maxHeight + _PopupViewState._arrowHeight);
  }

  @override
  _PopupViewState createState() => _PopupViewState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BoxConstraints>('constraints', constraints, showName: false));
    properties.add(DiagnosticsProperty<Color>('color', color, showName: false));
    properties.add(DiagnosticsProperty<double>('double', radius, showName: false));
  }
}

class _PopupViewState extends State<PopupDialog> with TickerProviderStateMixin {
  static const double _arrowWidth = 12.0;
  static const double _arrowHeight = 8.0;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _PopupPosition(
        attachRect: widget.attachRect,
        scale: widget.doubleAnimation,
        constraints: widget._getConstraints(),
        direction: widget.direction,
        child: _PopupBackground(
          attachRect: widget.attachRect,
          scale: widget.doubleAnimation,
          radius: widget.radius,
          color: widget.color,
          boxShadow: widget.boxShadow ?? [],
          direction: widget.direction,
          child: Material(type: MaterialType.transparency, child: widget.child),
        ),
      )
    ]);
  }
}

/// 弹出窗口相对点击弹窗按钮的位置
class _PopupPosition extends SingleChildRenderObjectWidget {
  final Rect attachRect;
  final Animation<double> scale;
  final BoxConstraints? constraints;
  final PopupDirection direction;

  const _PopupPosition({
    required Widget child,
    required this.attachRect,
    this.constraints,
    required this.scale,
    required this.direction,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) => _PopupPositionRenderObject(
        attachRect: attachRect,
        direction: direction,
        constraints: constraints ?? const BoxConstraints(),
      );

  @override
  void updateRenderObject(BuildContext context, _PopupPositionRenderObject renderObject) {
    renderObject
      ..attachRect = attachRect
      ..direction = direction
      ..additionalConstraints = constraints ?? const BoxConstraints();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BoxConstraints>('constraints', constraints, showName: false));
  }
}

class _PopupPositionRenderObject extends RenderShiftedBox {
  PopupDirection get direction => _direction;
  PopupDirection _direction;

  set direction(PopupDirection value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  Rect get attachRect => _attachRect;
  Rect _attachRect;

  set attachRect(Rect value) {
    if (_attachRect == value) return;
    _attachRect = value;
    markNeedsLayout();
  }

  BoxConstraints get additionalConstraints => _additionalConstraints;
  BoxConstraints _additionalConstraints;

  set additionalConstraints(BoxConstraints value) {
    if (_additionalConstraints == value) return;
    _additionalConstraints = value;
    markNeedsLayout();
  }

  _PopupPositionRenderObject({
    RenderBox? child,
    required Rect attachRect,
    BoxConstraints constraints = const BoxConstraints(),
    required PopupDirection direction,
  })  : _attachRect = attachRect,
        _additionalConstraints = constraints,
        _direction = direction,
        super(child);

  @override
  void performLayout() {
    child!.layout(_additionalConstraints.enforce(constraints), parentUsesSize: true);
    size = Size(constraints.maxWidth, constraints.maxHeight);

    final BoxParentData childParentData = child!.parentData as BoxParentData;
    childParentData.offset = calcOffset(child!.size);
  }

  /// 弹窗控件相对点击弹窗按钮整体的的偏移量
  Offset calcOffset(Size size) {
    PopupDirection calcDirection = _calcDirection(attachRect, size, direction);

    if (calcDirection == PopupDirection.leftTop ||
        calcDirection == PopupDirection.top ||
        calcDirection == PopupDirection.rightTop ||
        calcDirection == PopupDirection.leftBottom ||
        calcDirection == PopupDirection.bottom ||
        calcDirection == PopupDirection.rightBottom) {
      double bodyLeft = 0.0;
      // 上下
      if (attachRect.left > size.width / 2 && _screenWidth - attachRect.right > size.width / 2) {
        //判断是否可以在中间
        bodyLeft = attachRect.left + attachRect.width / 2 - size.width / 2;
      } else if (attachRect.left < size.width / 2) {
        //靠左
        bodyLeft = 0.0;
      } else {
        //靠右
        bodyLeft = _screenWidth - 0.0 - size.width;
      }

      if (calcDirection == PopupDirection.leftBottom || calcDirection == PopupDirection.bottom || calcDirection == PopupDirection.rightBottom) {
        return Offset(bodyLeft, attachRect.bottom);
      } else {
        return Offset(bodyLeft, attachRect.top - size.height);
      }
    } else {
      double bodyTop = 0.0;
      if (attachRect.top > size.height / 2 && _screenHeight - attachRect.bottom > size.height / 2) {
        //判断是否可以在中间
        bodyTop = attachRect.top + attachRect.height / 2 - size.height / 2;
      } else if (attachRect.top < size.height / 2) {
        //靠左
        bodyTop = 10.0;
      } else {
        //靠右
        bodyTop = _screenHeight - 10.0 - size.height;
      }

      if (calcDirection == PopupDirection.topRight || calcDirection == PopupDirection.right || calcDirection == PopupDirection.bottomRight) {
        return Offset(attachRect.right, bodyTop);
      } else {
        return Offset(attachRect.left - size.width, bodyTop);
      }
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BoxConstraints>('additionalConstraints', additionalConstraints));
  }
}

/// 弹出窗口显示的背景和动画
class _PopupBackground extends SingleChildRenderObjectWidget {
  final Rect attachRect;
  final Color color;
  final List<BoxShadow> boxShadow;
  final Animation<double> scale;
  final double radius;
  final PopupDirection direction;

  const _PopupBackground({
    required Widget child,
    required this.attachRect,
    required this.color,
    this.boxShadow = const [],
    required this.scale,
    required this.radius,
    required this.direction,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) => _PopupContextRenderObject(
        attachRect: attachRect,
        color: color,
        boxShadow: boxShadow,
        scale: scale.value,
        direction: direction,
        radius: radius,
      );

  @override
  void updateRenderObject(BuildContext context, _PopupContextRenderObject renderObject) {
    renderObject
      ..attachRect = attachRect
      ..color = color
      ..boxShadow = boxShadow
      ..scale = scale.value
      ..direction = direction
      ..radius = radius;
  }
}

class _PopupContextRenderObject extends RenderShiftedBox {
  PopupDirection get direction => _direction;
  PopupDirection _direction;

  set direction(PopupDirection value) {
    if (_direction == value) return;
    _direction = value;
    markNeedsLayout();
  }

  Rect get attachRect => _attachRect;
  Rect _attachRect;

  set attachRect(Rect value) {
    if (_attachRect == value) return;
    _attachRect = value;
    markNeedsLayout();
  }

  Color get color => _color;
  Color _color;

  set color(Color value) {
    if (_color == value) return;
    _color = value;
    markNeedsLayout();
  }

  List<BoxShadow> get boxShadow => _boxShadow;
  List<BoxShadow> _boxShadow;

  set boxShadow(List<BoxShadow> value) {
    if (_boxShadow == value) return;
    _boxShadow = value;
    markNeedsLayout();
  }

  double get scale => _scale;
  double _scale;

  set scale(double value) {
    if (_scale == value) return;
    _scale = value;
    markNeedsLayout();
  }

  double get radius => _radius;
  double _radius;

  set radius(double value) {
    if (_radius == value) return;
    _radius = value;
    markNeedsLayout();
  }

  _PopupContextRenderObject({
    RenderBox? child,
    required Rect attachRect,
    required Color color,
    List<BoxShadow> boxShadow = const [],
    required double scale,
    required double radius,
    required PopupDirection direction,
  })  : _attachRect = attachRect,
        _color = color,
        _boxShadow = boxShadow,
        _scale = scale,
        _radius = radius,
        _direction = direction,
        super(child);

  @override
  void performLayout() {
    assert(constraints.maxHeight.isFinite);
    BoxConstraints childConstraints;

    if (_isVertical()) {
      childConstraints = BoxConstraints(maxHeight: constraints.maxHeight - _PopupViewState._arrowHeight).enforce(constraints);
    } else {
      childConstraints = BoxConstraints(maxWidth: constraints.maxWidth - _PopupViewState._arrowHeight).enforce(constraints);
    }

    child!.layout(childConstraints, parentUsesSize: true);

    // 根据箭头指向的方向，测量控件的大小
    if (_isVertical()) {
      size = Size(child!.size.width, child!.size.height + _PopupViewState._arrowHeight);
    } else {
      size = Size(child!.size.width + _PopupViewState._arrowHeight, child!.size.height);
    }

    // 获取箭头的指向
    PopupDirection calcDirection = _calcDirection(attachRect, size, direction);
    final BoxParentData childParentData = child!.parentData as BoxParentData;
    if (calcDirection == PopupDirection.leftBottom || direction == PopupDirection.bottom || direction == PopupDirection.rightBottom) {
      childParentData.offset = const Offset(0.0, _PopupViewState._arrowHeight);
    } else if (direction == PopupDirection.topRight || direction == PopupDirection.right || direction == PopupDirection.bottomRight) {
      childParentData.offset = const Offset(_PopupViewState._arrowHeight, 0.0);
    }
  }

  bool _isVertical() {
    return direction == PopupDirection.leftTop ||
        direction == PopupDirection.top ||
        direction == PopupDirection.rightTop ||
        direction == PopupDirection.leftBottom ||
        direction == PopupDirection.bottom ||
        direction == PopupDirection.rightBottom;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    Matrix4 transform = Matrix4.identity();

    PopupDirection calcDirection = _calcDirection(attachRect, size, direction);

    Rect? arrowRect; // 绘制箭头三角形区域
    Offset? translation; // 弹窗动画展示
    Rect bodyRect; // 绘制弹窗主体区域

    final BoxParentData childParentData = (child!.parentData) as BoxParentData;
    bodyRect = childParentData.offset & child!.size;

    // 用于 leftTop和leftBottom 居左时相对左边(即X轴)的偏移量
    double offsetLeft = 20.0;
    // 用于 top和bottom 居中时相对左边(即X轴)的偏移量
    double offsetHorizontalCenter = attachRect.left + attachRect.width / 2 - _PopupViewState._arrowWidth / 2 - offset.dx;
    // 用于 rightTop和rightBottom 居右时相对左边(即X轴)的偏移量
    double offsetRight = child!.size.width - offsetLeft;
    // 用于 topLeft和topRight 居上时相对上边(即Y轴)的偏移量
    double offsetTop = 20.0;
    // 用于 left和right 居中时相对上边(即Y轴)的偏移量
    double offsetVerticalCenter = attachRect.top + attachRect.height / 2 - _PopupViewState._arrowWidth / 2 - offset.dy;
    // 用于 bottomLeft和bottomRight 居下时相对上边(即X轴)的偏移量
    double offsetBottom = child!.size.height - offsetTop;

    switch (calcDirection) {
      case PopupDirection.leftTop: // 顶部的左边
        arrowRect = Rect.fromLTWH(offsetLeft, child!.size.height, _PopupViewState._arrowWidth, _PopupViewState._arrowHeight);
        translation = Offset(offsetLeft + _PopupViewState._arrowWidth / 2, size.height);
        break;
      case PopupDirection.top: //正上方
        arrowRect = Rect.fromLTWH(offsetHorizontalCenter, child!.size.height, _PopupViewState._arrowWidth, _PopupViewState._arrowHeight);
        translation = Offset(offsetHorizontalCenter + _PopupViewState._arrowWidth / 2, size.height);
        break;
      case PopupDirection.rightTop: //顶部的右边
        arrowRect = Rect.fromLTWH(offsetRight, child!.size.height, _PopupViewState._arrowWidth, _PopupViewState._arrowHeight);
        translation = Offset(offsetRight + _PopupViewState._arrowWidth / 2, size.height);
        break;
      case PopupDirection.topLeft:
        arrowRect = Rect.fromLTWH(child!.size.width, offsetTop, _PopupViewState._arrowHeight, _PopupViewState._arrowWidth);
        translation = Offset(size.width, offsetTop + _PopupViewState._arrowWidth / 2);
        break;
      case PopupDirection.left:
        arrowRect = Rect.fromLTWH(child!.size.width, offsetVerticalCenter, _PopupViewState._arrowHeight, _PopupViewState._arrowWidth);
        translation = Offset(size.width, offsetVerticalCenter + _PopupViewState._arrowWidth / 2);
        break;
      case PopupDirection.bottomLeft:
        arrowRect = Rect.fromLTWH(child!.size.width, offsetBottom, _PopupViewState._arrowHeight, _PopupViewState._arrowWidth);
        translation = Offset(size.width, offsetBottom + _PopupViewState._arrowWidth / 2);
        break;
      case PopupDirection.leftBottom:
        arrowRect = Rect.fromLTWH(offsetLeft, 0, _PopupViewState._arrowWidth, _PopupViewState._arrowHeight);
        translation = Offset(offsetLeft + _PopupViewState._arrowWidth / 2, 0);
        break;
      case PopupDirection.bottom:
        arrowRect = Rect.fromLTWH(offsetHorizontalCenter, 0, _PopupViewState._arrowWidth, _PopupViewState._arrowHeight);
        translation = Offset(offsetHorizontalCenter + _PopupViewState._arrowWidth / 2, 0);
        break;
      case PopupDirection.rightBottom:
        arrowRect = Rect.fromLTWH(offsetRight, 0, _PopupViewState._arrowWidth, _PopupViewState._arrowHeight);
        translation = Offset(offsetRight + _PopupViewState._arrowWidth / 2, 0);
        break;
      case PopupDirection.topRight:
        arrowRect = Rect.fromLTWH(0, offsetTop, _PopupViewState._arrowHeight, _PopupViewState._arrowWidth);
        translation = Offset(0, offsetTop + _PopupViewState._arrowWidth / 2);
        break;
      case PopupDirection.right:
        arrowRect = Rect.fromLTWH(0, offsetVerticalCenter, _PopupViewState._arrowHeight, _PopupViewState._arrowWidth);
        translation = Offset(0, offsetVerticalCenter + _PopupViewState._arrowWidth / 2);
        break;
      case PopupDirection.bottomRight:
        arrowRect = Rect.fromLTWH(0, offsetBottom, _PopupViewState._arrowHeight, _PopupViewState._arrowWidth);
        translation = Offset(0, offsetBottom + _PopupViewState._arrowWidth / 2);
        break;
    }

    transform.translate(translation.dx, translation.dy);
    transform.scale(scale, scale, 1.0);
    transform.translate(-translation.dx, -translation.dy);

    _paintShadows(context, transform, offset, calcDirection, arrowRect, bodyRect);

    Path clipPath = _getPath(calcDirection, arrowRect, bodyRect);
    context.pushClipPath(needsCompositing, offset, offset & size, clipPath, (context, offset) {
      context.pushTransform(needsCompositing, offset, transform, (context, offset) {
        final Paint backgroundPaint = Paint();
        backgroundPaint.color = color;
        context.canvas.drawRect(offset & size, backgroundPaint);
        super.paint(context, offset);
      });
    });
  }

  void _paintShadows(PaintingContext context, Matrix4 transform, Offset offset, PopupDirection direction, Rect arrowRect, Rect bodyRect) {
    for (final BoxShadow boxShadow in boxShadow) {
      final Paint paint = boxShadow.toPaint();
      arrowRect = arrowRect.shift(offset).shift(boxShadow.offset).inflate(boxShadow.spreadRadius);
      bodyRect = bodyRect.shift(offset).shift(boxShadow.offset).inflate(boxShadow.spreadRadius);
      Path path = _getPath(direction, arrowRect, bodyRect);

      context.pushTransform(needsCompositing, offset, transform, (context, offset) {
        context.canvas.drawPath(path, paint);
      });
    }
  }

  /// 获取裁剪的箭头指向路径
  /// direction 箭头指向的方向
  /// arrowRect 箭头相对位置的区域
  /// bodyRect  主体相对位置的区域
  Path _getPath(PopupDirection direction, Rect arrowRect, Rect bodyRect) {
    Path path = Path();

    if (direction == PopupDirection.leftTop || direction == PopupDirection.top || direction == PopupDirection.rightTop) {
      path.moveTo(arrowRect.left, arrowRect.top); //箭头
      path.lineTo(arrowRect.left + arrowRect.width / 2, arrowRect.bottom);
      path.lineTo(arrowRect.right, arrowRect.top);

      path.lineTo(bodyRect.right - radius, bodyRect.bottom); //右下角
      path.conicTo(bodyRect.right, bodyRect.bottom, bodyRect.right, bodyRect.bottom - radius, 1.0);

      path.lineTo(bodyRect.right, bodyRect.top + radius); //右上角
      path.conicTo(bodyRect.right, bodyRect.top, bodyRect.right - radius, bodyRect.top, 1.0);

      path.lineTo(bodyRect.left + radius, bodyRect.top); //左上角
      path.conicTo(bodyRect.left, bodyRect.top, bodyRect.left, bodyRect.top + radius, 1.0);

      path.lineTo(bodyRect.left, bodyRect.bottom - radius); //左下角
      path.conicTo(bodyRect.left, bodyRect.bottom, bodyRect.left + radius, bodyRect.bottom, 1.0);
    } else if (direction == PopupDirection.topRight || direction == PopupDirection.right || direction == PopupDirection.bottomRight) {
      path.moveTo(arrowRect.right, arrowRect.top); //箭头
      path.lineTo(arrowRect.left, arrowRect.top + arrowRect.height / 2);
      path.lineTo(arrowRect.right, arrowRect.bottom);

      path.lineTo(bodyRect.left, bodyRect.bottom - radius); //左下角
      path.conicTo(bodyRect.left, bodyRect.bottom, bodyRect.left + radius, bodyRect.bottom, 1.0);

      path.lineTo(bodyRect.right - radius, bodyRect.bottom); //右下角
      path.conicTo(bodyRect.right, bodyRect.bottom, bodyRect.right, bodyRect.bottom - radius, 1.0);

      path.lineTo(bodyRect.right, bodyRect.top + radius); //右上角
      path.conicTo(bodyRect.right, bodyRect.top, bodyRect.right - radius, bodyRect.top, 1.0);

      path.lineTo(bodyRect.left + radius, bodyRect.top); //左上角
      path.conicTo(bodyRect.left, bodyRect.top, bodyRect.left, bodyRect.top + radius, 1.0);
    } else if (direction == PopupDirection.topLeft || direction == PopupDirection.left || direction == PopupDirection.bottomLeft) {
      path.moveTo(arrowRect.left, arrowRect.top); //箭头
      path.lineTo(arrowRect.right, arrowRect.top + arrowRect.height / 2);
      path.lineTo(arrowRect.left, arrowRect.bottom);

      path.lineTo(bodyRect.right, bodyRect.bottom - radius); //右下角
      path.conicTo(bodyRect.right, bodyRect.bottom, bodyRect.right - radius, bodyRect.bottom, 1.0);

      path.lineTo(bodyRect.left + radius, bodyRect.bottom); //左下角
      path.conicTo(bodyRect.left, bodyRect.bottom, bodyRect.left, bodyRect.bottom - radius, 1.0);

      path.lineTo(bodyRect.left, bodyRect.top + radius); //左上角
      path.conicTo(bodyRect.left, bodyRect.top, bodyRect.left + radius, bodyRect.top, 1.0);

      path.lineTo(bodyRect.right - radius, bodyRect.top); //右上角
      path.conicTo(bodyRect.right, bodyRect.top, bodyRect.right, bodyRect.top + radius, 1.0);
    } else if (direction == PopupDirection.leftBottom || direction == PopupDirection.bottom || direction == PopupDirection.rightBottom) {
      path.moveTo(arrowRect.left, arrowRect.bottom); //箭头
      path.lineTo(arrowRect.left + arrowRect.width / 2, arrowRect.top);
      path.lineTo(arrowRect.right, arrowRect.bottom);

      path.lineTo(bodyRect.right - radius, bodyRect.top); //右上角
      path.conicTo(bodyRect.right, bodyRect.top, bodyRect.right, bodyRect.top + radius, 1.0);

      path.lineTo(bodyRect.right, bodyRect.bottom - radius); //右下角
      path.conicTo(bodyRect.right, bodyRect.bottom, bodyRect.right - radius, bodyRect.bottom, 1.0);

      path.lineTo(bodyRect.left + radius, bodyRect.bottom); //左下角
      path.conicTo(bodyRect.left, bodyRect.bottom, bodyRect.left, bodyRect.bottom - radius, 1.0);

      path.lineTo(bodyRect.left, bodyRect.top + radius); //左上角
      path.conicTo(bodyRect.left, bodyRect.top, bodyRect.left + radius, bodyRect.top, 1.0);
    }
    path.close();
    return path;
  }
}

PopupDirection _calcDirection(Rect attachRect, Size size, PopupDirection direction) {
  if (direction == PopupDirection.leftTop || direction == PopupDirection.leftBottom) {
    return (attachRect.top < size.height + _PopupViewState._arrowHeight) ? PopupDirection.leftBottom : PopupDirection.leftTop; // 判断上下位置够不够
  } else if (direction == PopupDirection.top || direction == PopupDirection.bottom) {
    return (attachRect.top < size.height + _PopupViewState._arrowHeight) ? PopupDirection.bottom : PopupDirection.top;
  } else if (direction == PopupDirection.rightTop || direction == PopupDirection.rightBottom) {
    return (attachRect.top < size.height + _PopupViewState._arrowHeight) ? PopupDirection.rightBottom : PopupDirection.rightTop;
  } else if (direction == PopupDirection.topLeft || direction == PopupDirection.topRight) {
    return (attachRect.left < size.width + _PopupViewState._arrowHeight) ? PopupDirection.topRight : PopupDirection.topLeft; // 判断左右位置够不够
  } else if (direction == PopupDirection.left || direction == PopupDirection.right) {
    return (attachRect.left < size.width + _PopupViewState._arrowHeight) ? PopupDirection.right : PopupDirection.left;
  } else if (direction == PopupDirection.bottomLeft || direction == PopupDirection.bottomRight) {
    return (attachRect.left < size.width + _PopupViewState._arrowHeight) ? PopupDirection.bottomRight : PopupDirection.bottomLeft;
  } else {
    return PopupDirection.bottom;
  }
}
