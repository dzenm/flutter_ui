import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum PopupDirection { top, bottom, left, right }

typedef BoolCallback = bool Function();

double get _screenWidth => MediaQueryData.fromWindow(window).size.width;

double get _screenHeight => MediaQueryData.fromWindow(window).size.height;

/// 显示弹出窗口所在的widget
class PopupButton extends StatelessWidget {
  final Widget child;
  final WidgetBuilder? builder;
  final double? width;
  final double? height;
  final double elevation;
  final BoxConstraints? boxConstraints;
  final Color color;
  final List<BoxShadow>? boxShadow;
  final double radius;
  final Color barrierColor;
  final BoolCallback? onTap;
  final Duration transitionDuration;
  final PopupDirection direction;

  PopupButton({
    Key? key,
    required this.child,
    this.builder,
    this.width,
    this.height,
    this.elevation = 0.0,
    BoxConstraints? boxConstraints,
    this.color = Colors.white,
    this.boxShadow,
    this.radius = 8.0,
    this.barrierColor = Colors.black54,
    this.onTap,
    this.transitionDuration = const Duration(milliseconds: 200),
    this.direction = PopupDirection.bottom,
  })  : assert(builder != null),
        boxConstraints = (width != null || height != null) ? boxConstraints?.tighten(width: width, height: height) ?? BoxConstraints.tightFor(width: width, height: height) : boxConstraints,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child,
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (onTap != null && onTap!()) {
          return;
        }
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
            body = builder!(context);
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: PopupView(
                child: body,
                doubleAnimation: animation,
                attachRect: Rect.fromLTWH(offset.dx, offset.dy, bounds.width, bounds.height),
                constraints: boxConstraints,
                color: color,
                boxShadow: boxShadow,
                radius: radius,
                direction: direction,
              ),
            );
          },
        );
      },
    );
  }
}

/// 弹出窗口
class PopupView extends StatefulWidget {
  final Widget child;
  final Animation<double> doubleAnimation;
  final Rect attachRect;
  final BoxConstraints? constraints;
  final Color color;
  final List<BoxShadow>? boxShadow;
  final double radius;
  final PopupDirection direction;

  const PopupView({
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

class _PopupViewState extends State<PopupView> with TickerProviderStateMixin {
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
        child: _PopupContext(
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

/// 弹出窗口所在的位置
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

  Offset calcOffset(Size size) {
    PopupDirection calcDirection = _calcDirection(attachRect, size, direction);

    if (calcDirection == PopupDirection.top || calcDirection == PopupDirection.bottom) {
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

      if (calcDirection == PopupDirection.bottom) {
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

      if (calcDirection == PopupDirection.right) {
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

class _PopupContext extends SingleChildRenderObjectWidget {
  final Rect attachRect;
  final Color color;
  final List<BoxShadow> boxShadow;
  final Animation<double> scale;
  final double radius;
  final PopupDirection direction;

  const _PopupContext({
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
    // print('scale:${_scale.value}');
    // if (_scale == value)
    //   return;
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

    if (direction == PopupDirection.top || direction == PopupDirection.bottom) {
      childConstraints = BoxConstraints(maxHeight: constraints.maxHeight - _PopupViewState._arrowHeight).enforce(constraints);
    } else {
      childConstraints = BoxConstraints(maxWidth: constraints.maxWidth - _PopupViewState._arrowHeight).enforce(constraints);
    }

    child!.layout(childConstraints, parentUsesSize: true);

    if (direction == PopupDirection.top || direction == PopupDirection.bottom) {
      size = Size(child!.size.width, child!.size.height + _PopupViewState._arrowHeight);
    } else {
      size = Size(child!.size.width + _PopupViewState._arrowHeight, child!.size.height);
    }
    PopupDirection calcDirection = _calcDirection(attachRect, size, direction);

    final BoxParentData childParentData = child!.parentData as BoxParentData;
    if (calcDirection == PopupDirection.bottom) {
      childParentData.offset = const Offset(0.0, _PopupViewState._arrowHeight);
    } else if (calcDirection == PopupDirection.right) {
      childParentData.offset = const Offset(_PopupViewState._arrowHeight, 0.0);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // TODO: implement paint
    Matrix4 transform = Matrix4.identity();
//

    PopupDirection calcDirection = _calcDirection(attachRect, size, direction);

    Rect? arrowRect;
    Offset? translation;
    Rect bodyRect;

    final BoxParentData childParentData = (child!.parentData) as BoxParentData;
    bodyRect = childParentData.offset & child!.size;

    var arrowLeft = attachRect.left + // 用于 Top和Bottom
        attachRect.width / 2 -
        _PopupViewState._arrowWidth / 2 -
        offset.dx;

    var arrowTop = attachRect.top + // 用于 Left和Right
        attachRect.height / 2 -
        _PopupViewState._arrowWidth / 2 -
        offset.dy;

    switch (calcDirection) {
      case PopupDirection.top:
        arrowRect = Rect.fromLTWH(arrowLeft, child!.size.height, _PopupViewState._arrowWidth, _PopupViewState._arrowHeight);
        translation = Offset(arrowLeft + _PopupViewState._arrowWidth / 2, size.height);

        break;
      case PopupDirection.left:
        arrowRect = Rect.fromLTWH(child!.size.width, arrowTop, _PopupViewState._arrowHeight, _PopupViewState._arrowWidth);
        translation = Offset(size.width, arrowTop + _PopupViewState._arrowWidth / 2);
        break;
      case PopupDirection.bottom:
        arrowRect = Rect.fromLTWH(arrowLeft, 0, _PopupViewState._arrowWidth, _PopupViewState._arrowHeight);
        translation = Offset(arrowLeft + _PopupViewState._arrowWidth / 2, 0);
        break;
      case PopupDirection.right:
        arrowRect = Rect.fromLTWH(0, arrowTop, _PopupViewState._arrowHeight, _PopupViewState._arrowWidth);
        translation = Offset(0, arrowTop + _PopupViewState._arrowWidth / 2);
        break;
      default:
    }

    transform.translate(translation!.dx, translation.dy);
    transform.scale(scale, scale, 1.0);
    transform.translate(-translation.dx, -translation.dy);

    _paintShadows(context, transform, offset, calcDirection, arrowRect!, bodyRect);

    Path clipPath = _getClip(calcDirection, arrowRect, bodyRect);
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
      Path path = _getClip(direction, arrowRect, bodyRect);

      context.pushTransform(needsCompositing, offset, transform, (context, offset) {
        context.canvas.drawPath(path, paint);
      });
    }
  }

  Path _getClip(PopupDirection direction, Rect arrowRect, Rect bodyRect) {
    Path path = Path();

    if (direction == PopupDirection.top) {
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
    } else if (direction == PopupDirection.right) {
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
    } else if (direction == PopupDirection.left) {
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
    } else {
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
  switch (direction) {
    case PopupDirection.top:
      return (attachRect.top < size.height + _PopupViewState._arrowHeight) ? PopupDirection.bottom : PopupDirection.top; // 判断顶部位置够不够
    case PopupDirection.bottom:
      return _screenHeight > attachRect.bottom + size.height + _PopupViewState._arrowHeight ? PopupDirection.bottom : PopupDirection.top;
    case PopupDirection.left:
      return (attachRect.left < size.width + _PopupViewState._arrowHeight) ? PopupDirection.right : PopupDirection.left; // 判断顶部位置够不够
    case PopupDirection.right:
      return _screenWidth > attachRect.right + size.width + _PopupViewState._arrowHeight ? PopupDirection.right : PopupDirection.left;
  }
}

///get Widget Bounds (width, height, left, top, right, bottom and so on).Widgets must be rendered completely.
///获取Widget Rect
Rect _getWidgetBounds(BuildContext context) {
  RenderBox? box = context.findRenderObject() as RenderBox?;
  return (box != null) ? box.semanticBounds : Rect.zero;
}

///Get the coordinates of the widget on the screen.Widgets must be rendered completely.
///获取widget在屏幕上的坐标,widget必须渲染完成
Offset _getWidgetLocalToGlobal(BuildContext context) {
  RenderBox? box = context.findRenderObject() as RenderBox?;
  return box == null ? Offset.zero : box.localToGlobal(Offset.zero);
}
