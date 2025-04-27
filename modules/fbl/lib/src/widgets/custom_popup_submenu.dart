import 'package:flutter/material.dart';

import 'tap.dart';

const Duration _kWindowDuration = Duration(milliseconds: 0);
const double _kWindowCloseIntervalEnd = 2.0 / 3.0;
const double _kWindowMaxWidth = 240.0;
const double _kWindowMinWidth = 48.0;
const double _kWindowVerticalPadding = 0.0;
const double _kWindowScreenPadding = 0.0;

/// 自定义弹窗控件：对自定义的弹窗内容长宽进行包装
class CustomPopupSubmenu<T> extends StatelessWidget {
  const CustomPopupSubmenu({
    super.key,
    required this.child,
    this.semanticLabel,
    this.constraints,
  });

  final Widget child;
  final String? semanticLabel;
  final BoxConstraints? constraints;

  ///弹窗方法
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    required RelativeRect position,
    double elevation = 8.0,
    String? semanticLabel,
    BoxConstraints? constraints,
  }) async {
    Route<T> route = _CustomPopupSubmenuRoute(
      position: position,
      elevation: elevation,
      theme: Theme.of(context),
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      builder: (route) {
        return _buildContentView(
          child: CustomPopupSubmenu<T>(
            semanticLabel: semanticLabel ?? MaterialLocalizations.of(context).popupMenuLabel,
            constraints: constraints,
            child: child,
          ),
        );
      },
    );
    return await Navigator.push<T>(context, route);
  }

  static Future<T?> showList<T>(
    BuildContext context,
    GlobalKey targetKey,
    List<String> items, {
    void Function(String item)? onTap,
    Alignment? alignment,
    double width = 100,
  }) async {
    // GlobalKey popupKey = GlobalKey();
    RenderBox targetView = targetKey.currentContext!.findRenderObject() as RenderBox;
    // RenderBox popupChildView = popupKey.currentContext!.findRenderObject() as RenderBox;
    RenderBox popupView = Overlay.of(context).context.findRenderObject() as RenderBox;
    Offset a = targetView.localToGlobal(Offset(targetView.size.width, targetView.size.height), ancestor: popupView);
    Offset b;

    double fromTopDis = targetView.localToGlobal(const Offset(0, 0)).dy;
    double popHeight = (12 + items.length + items.length * 35).toDouble();
    if (fromTopDis - popHeight > 32) {
      //menu不能覆盖到toolbar上方
      b = targetView.localToGlobal(targetView.size.topLeft(Offset(0, -popHeight)), ancestor: popupView);
    } else {
      b = targetView.localToGlobal(targetView.size.bottomLeft(const Offset(0, 0.0)), ancestor: popupView);
    }
    RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(a, b),
      Offset.zero & popupView.size,
    );

    return await show<T>(
      context: context,
      position: position,
      elevation: 0.0,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          // key: popupKey,
          width: width,
          padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xffE6E6E6), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: items
                .map(
                  (item) => Column(children: [
                    TapLayout(
                      height: 35,
                      alignment: alignment,
                      foreground: Colors.transparent,
                      onTap: () {
                        Navigator.pop(context);
                        if (onTap != null) onTap(item);
                      },
                      child: Text(item, style: const TextStyle(fontSize: 16)),
                    ),
                    if (items.indexOf(item) != items.length - 1)
                      const Divider(
                        height: 0.5,
                        indent: 0,
                        endIndent: 0,
                        color: Color(0xFFEEEEEE),
                      ),
                  ]),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  static Widget _buildContentView({required Widget child}) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 0.5),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 10.0,
            spreadRadius: 0.0,
            color: Color(0x0D000000),
          ),
          BoxShadow(
            offset: Offset(0, 1),
            blurRadius: 4.0,
            spreadRadius: 0.0,
            color: Color(0x14000000),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: constraints ??
          const BoxConstraints(
            minWidth: _kWindowMinWidth,
            maxWidth: _kWindowMaxWidth,
          ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: _kWindowVerticalPadding),
        child: child,
      ),
    );
  }
}

/// 自定义弹窗路由：添加弹出位置、动画等约束条件
class _CustomPopupSubmenuRoute<T> extends PopupRoute<T> {
  _CustomPopupSubmenuRoute({
    required this.builder,
    required this.position,
    this.elevation = 8.0,
    this.theme,
    this.backgroundColor = Colors.transparent,
    this.barrierLabel,
  }) : super();

  final Widget Function(PopupRoute route) builder;
  final RelativeRect position;
  final double elevation;
  final ThemeData? theme;
  final Color? backgroundColor; // const Color(0x99000000)

  @override
  bool get barrierDismissible => true;

  @override
  final String? barrierLabel;

  @override
  Duration get transitionDuration => _kWindowDuration;

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(
      parent: super.createAnimation(),
      curve: Curves.linear,
      reverseCurve: const Interval(0.0, _kWindowCloseIntervalEnd),
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    const double length = 10.0;
    const double unit = 1.0 / (length + 1.5); // 1.0 for the width and 0.5 for the last item's fade.
    CurveTween opacity = CurveTween(curve: const Interval(0.0, 1.0 / 3.0));
    CurveTween width = CurveTween(curve: const Interval(0.0, unit));
    CurveTween height = CurveTween(curve: const Interval(0.0, unit * length));

    Widget child = AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: opacity.evaluate(animation),
          child: Material(
            type: elevation == 0 ? MaterialType.transparency : MaterialType.card,
            elevation: elevation,
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              widthFactor: width.evaluate(animation),
              heightFactor: height.evaluate(animation),
              child: Semantics(
                scopesRoute: true,
                namesRoute: true,
                explicitChildNodes: true,
                child: child,
              ),
            ),
          ),
        );
      },
      child: builder(this),
    );
    if (theme != null) {
      child = Theme(data: theme!, child: child);
    }
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      removeBottom: true,
      removeLeft: true,
      removeRight: true,
      child: Builder(
        builder: (BuildContext context) {
          return Material(
            type: MaterialType.transparency,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: backgroundColor,
                child: CustomSingleChildLayout(
                  delegate: _CustomPopupSubmenuLayoutDelegate(position, null, Directionality.of(context)),
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Color? get barrierColor => null;
}

/// 自定义委托内容：子控件大小及其位置计算
class _CustomPopupSubmenuLayoutDelegate extends SingleChildLayoutDelegate {
  _CustomPopupSubmenuLayoutDelegate(this.position, this.selectedItemOffset, this.textDirection);

  final RelativeRect position;
  final double? selectedItemOffset;
  final TextDirection textDirection;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The menu can be at most the size of the overlay minus 8.0 pixels in each
    // direction.
    return BoxConstraints.loose(
      (constraints.biggest - const Offset(_kWindowScreenPadding * 2.0, _kWindowScreenPadding * 2.0)) as Size,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // size: The size of the overlay.
    // childSize: The size of the menu, when fully open, as determined by
    // getConstraintsForChild.

    // Find the ideal vertical position.
    double y;
    if (selectedItemOffset == null) {
      y = position.top;
    } else {
      y = position.top + (size.height - position.top - position.bottom) / 2.0 - (selectedItemOffset ?? 0);
    }

    // Find the ideal horizontal position.
    double x;
    if (position.left > position.right) {
      // Menu button is closer to the right edge, so grow to the left, aligned to the right edge.
      x = size.width - position.right - childSize.width;
    } else if (position.left < position.right) {
      // Menu button is closer to the left edge, so grow to the right, aligned to the left edge.
      x = position.left;
    } else {
      // Menu button is equidistant from both edges, so grow in reading direction.
      switch (textDirection) {
        case TextDirection.rtl:
          x = size.width - position.right - childSize.width;
          break;
        case TextDirection.ltr:
          x = position.left;
          break;
      }
    }

    // Avoid going outside an area defined as the rectangle 8.0 pixels from the
    // edge of the screen in every direction.
    if (x < _kWindowScreenPadding) {
      x = _kWindowScreenPadding;
    } else if (x + childSize.width > size.width - _kWindowScreenPadding) {
      x = size.width - childSize.width - _kWindowScreenPadding;
    }
    if (y < _kWindowScreenPadding) {
      y = _kWindowScreenPadding;
    } else if (y + childSize.height > size.height - _kWindowScreenPadding) {
      y = size.height - childSize.height - _kWindowScreenPadding;
    }
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_CustomPopupSubmenuLayoutDelegate oldDelegate) {
    return position != oldDelegate.position;
  }
}

/// 弹出框菜单展示的方向
enum MenuDirection {
  left,
  top,
  right,
  bottom,
}
