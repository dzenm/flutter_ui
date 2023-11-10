import 'package:flutter/material.dart';

///create by elileo on 2018/12/21
///https://github.com/elileo1/flutter_travel_friends/blob/master/lib/widget/PopupWindow.dart
///
/// weilu update： 去除了IntrinsicWidth限制，添加了默认蒙版
const Duration _kWindowDuration = Duration(milliseconds: 0);
const double _kWindowCloseIntervalEnd = 2.0 / 3.0;
const double _kWindowMaxWidth = 240.0;
const double _kWindowMinWidth = 48.0;
const double _kWindowVerticalPadding = 0.0;
const double _kWindowScreenPadding = 0.0;

/// 自定义弹窗控件：对自定义的弹窗内容进行再包装，添加长宽、动画等约束条件
class CustomPopupMenu<T> extends StatelessWidget {
  /// [delegate] CustomPopupMenu在目标所在范围的Key
  static Future<T?> show<T>({
    required BuildContext context,
    required GlobalKey targetScopeKey,
    required Widget child,
    Color barrierColor = const Color(0x99000000),
    SingleChildLayoutDelegate? delegate,
    double elevation = 8.0,
  }) {
    Route<T> route = _CustomPopupRoute(
      delegate: delegate ?? _buildDelegate(context, targetScopeKey),
      theme: Theme.of(context),
      elevation: elevation,
      color: barrierColor,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      child: CustomPopupMenu<T>(child: child),
    );
    return Navigator.push(context, route);
  }

  static Future<T?> showPopupMoreMenu<T>(
    BuildContext context,
    GlobalKey targetScopeKey,
    GlobalKey moreKey,
    List<String> optionList,
    Function menuItem,
  ) async {
    final RenderBox button = moreKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    var a = button.localToGlobal(Offset(button.size.width - 8.0, button.size.height - 12.0), ancestor: overlay);
    var b = button.localToGlobal(button.size.bottomLeft(const Offset(0, -12.0)), ancestor: overlay);
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(a, b),
      Offset.zero & overlay.size,
    );
    return await show(
      context: context,
      targetScopeKey: targetScopeKey,
      elevation: 0.0,
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xffcccccc), width: 1),
          ),
          child: Column(
            children: optionList.map<Widget>((title) {
              return menuItem(title);
            }).toList(),
          ),
        ),
      ),
    );
  }

  static SingleChildLayoutDelegate _buildDelegate(BuildContext context, GlobalKey targetScopeKey) {
    // Popup展示所在的target布局
    RenderBox target = Overlay.of(context).context.findRenderObject() as RenderBox;
    // 弹窗限制的范围的布局
    RenderBox scope = targetScopeKey.currentContext!.findRenderObject() as RenderBox;
    // 获取限制范围的大小
    Size scopeSize = scope.size;
    // 组件(scope)的坐标值(参数Offset)为相对ancestor参数(target)的坐标值(返回的参数Offset)
    Offset a = scope.localToGlobal(Offset(scopeSize.width, scopeSize.height), ancestor: target);
    Offset b;
    // 组件相对全屏的坐标y值(到顶部的距离)
    double fromTop = scope.localToGlobal(Offset.zero).dy;
    // 计算Popup的高度
    double popupHeight = 0;
    if (fromTop - popupHeight > 32) {
      // 如果Popup的高度未超出顶部的屏幕范围
      // 优先展示在上方
      b = scope.localToGlobal(scopeSize.topLeft(Offset(0, -popupHeight)), ancestor: target);
    } else {
      // 展示在下面
      b = scope.localToGlobal(scopeSize.bottomLeft(Offset.zero), ancestor: target);
    }

    RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(a, b),
      Offset.zero & target.size,
    );
    return _PopupWindowLayoutDelegate(position, Directionality.of(context));
  }

  const CustomPopupMenu({
    super.key,
    required this.child,
  });

  final Widget child; // 弹出框展示的布局

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: _kWindowVerticalPadding),
      child: child,
    );
  }
}

/// 自定义弹窗路由
class _CustomPopupRoute<T> extends PopupRoute<T> {
  _CustomPopupRoute({
    required this.delegate,
    required this.child,
    this.theme,
    this.elevation = 8.0,
    this.barrierLabel,
    required this.color,
  }) : super();

  final SingleChildLayoutDelegate delegate;
  final Widget child;
  final ThemeData? theme;
  final double elevation;
  final Color color;

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
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    Widget child = this.child;
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
                color: color,
                child: CustomSingleChildLayout(
                  delegate: delegate,
                  child: AnimatedBuilder(
                    animation: animation,
                    builder: (BuildContext context, Widget? child) {
                      const double length = 10.0;
                      const double unit = 1.0 / (length + 1.5); // 1.0 for the width and 0.5 for the last item's fade.
                      final CurveTween opacity = CurveTween(curve: const Interval(0.0, 1.0 / 3.0));
                      final CurveTween width = CurveTween(curve: const Interval(0.0, unit));
                      final CurveTween height = CurveTween(curve: const Interval(0.0, unit * length));
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
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: _kWindowMinWidth,
                        maxWidth: _kWindowMaxWidth,
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: _kWindowVerticalPadding),
                        child: child,
                      ),
                    ),
                  ),
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
class _PopupWindowLayoutDelegate extends SingleChildLayoutDelegate {
  _PopupWindowLayoutDelegate(this.position, this.textDirection);

  final RelativeRect position;
  final TextDirection textDirection;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    // The menu can be at most the size of the overlay minus 8.0 pixels in each
    // direction.
    return BoxConstraints.loose((constraints.biggest - const Offset(_kWindowScreenPadding * 2.0, _kWindowScreenPadding * 2.0)) as Size);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // size: The size of the overlay.
    // childSize: The size of the menu, when fully open, as determined by
    // getConstraintsForChild.

    // Find the ideal vertical position.
    double y = position.top;
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
  bool shouldRelayout(_PopupWindowLayoutDelegate oldDelegate) {
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
