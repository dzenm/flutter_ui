import 'package:flutter/material.dart';

import 'tap_layout.dart';

typedef ItemTapCallback = void Function(int index);

///
/// Created by a0010 on 2022/11/25 13:51
///
/// PopupWindow, 在任意target的指定方向显示一个child
class CustomPopupWindow extends StatefulWidget {
  /// 创建一个自定义的PopupWindow
  static void show(
    context,
    GlobalKey targetKey,
    Widget child, {
    PopDirection? direction,
    double? offset,
  }) {
    Navigator.push(
      context,
      CustomPopupRoute(
        child: CustomPopupWindow(
          targetKey: targetKey,
          child: child,
          direction: direction ?? PopDirection.bottom,
          offset: offset ?? 4,
        ),
      ),
    );
  }

  /// SizedBox(
  ///   key: targetKey,
  ///   width: 100,
  ///   height: 42,
  ///   color: Colors.amberAccent,
  ///   child: Text("Custom", style: TextStyle(color: Colors.white)),
  ///   child: FlatButton(
  ///     onPressed: () {
  ///       CustomPopupWindow.showList(context, targetKey, ['全选', '复制', '粘贴']);
  ///     },
  ///  )
  /// 创建一个列表的PopupWindow
  static void showList(
    context,
    GlobalKey targetKey,
    List<String> titles, {
    double radius = 8,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    PopDirection? direction,
    double? offset,
    ItemTapCallback? onItemTap,
  }) {
    Navigator.push(
      context,
      CustomPopupRoute(
        child: CustomPopupWindow(
          targetKey: targetKey,
          child: _PopupWindowState._buildListView(
            context,
            titles,
            radius: radius,
            padding: padding,
            margin: margin,
            color: color,
            onItemTap: onItemTap,
          ),
          direction: direction ?? PopDirection.bottom,
          offset: offset ?? 4,
        ),
      ),
    );
  }

  final Key? key;
  final GlobalKey targetKey; //展示的target key
  final Widget child; //自定义widget
  final PopDirection direction; //PopupWindow在target的方向
  final double offset; //PopupWindow偏移量

  CustomPopupWindow({
    this.key,
    required this.targetKey,
    required this.child,
    this.direction = PopDirection.bottom,
    this.offset = 0,
  });

  @override
  State<StatefulWidget> createState() => _PopupWindowState();
}

class _PopupWindowState extends State<CustomPopupWindow> {
  GlobalKey? popupWindowKey;
  double left = -100; // Popup初始位置，不能展示在屏幕内，所以设置为负数
  double top = -100; // Popup初始位置，不能展示在屏幕内，所以设置为负数

  @override
  void initState() {
    super.initState();
    popupWindowKey = GlobalKey();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox? target = widget.targetKey.currentContext?.findRenderObject() as RenderBox?;
      print('RenderBox target is ${target == null ? 'Null' : 'Not Null'}');
      if (target != null) {
        // TargetWidget的坐标位置
        Offset localToGlobal = target.localToGlobal(Offset.zero);
        // 如果想获得控件正下方的坐标：
        // Offset localToGlobal = target.localToGlobal(Offset(0.0, targetSize.height));

        // TargetWidget的大小
        Size targetSize = target.size;

        RenderBox popupWindow = popupWindowKey?.currentContext?.findRenderObject() as RenderBox;
        // PopupWindow的大小
        Size popupWindowSize = popupWindow.size;
        switch (widget.direction) {
          case PopDirection.left:
            left = localToGlobal.dx - popupWindowSize.width - widget.offset;
            top = localToGlobal.dy + targetSize.height / 2 - popupWindowSize.height / 2;
            break;
          case PopDirection.top:
            left = localToGlobal.dx + targetSize.width / 2 - popupWindowSize.width / 2;
            top = localToGlobal.dy - popupWindowSize.height - widget.offset;
            fixPosition(popupWindowSize);
            break;
          case PopDirection.right:
            left = localToGlobal.dx + targetSize.width + widget.offset;
            top = localToGlobal.dy + targetSize.height / 2 - popupWindowSize.height / 2;
            break;
          case PopDirection.bottom:
            left = localToGlobal.dx + targetSize.width / 2 - popupWindowSize.width / 2;
            top = localToGlobal.dy + targetSize.height + widget.offset;
            fixPosition(popupWindowSize);
            break;
        }
      }
      setState(() {});
    });
  }

  void fixPosition(Size popupWindowSize) {
    if (left < 0) {
      left = 0;
    }
    if (left + popupWindowSize.width >= MediaQuery.of(context).size.width) {
      left = MediaQuery.of(context).size.width - popupWindowSize.width;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
            ),
            Positioned(
              child: GestureDetector(
                child: _buildCustomWidget(widget.child),
              ),
              left: left,
              top: top,
            )
          ],
        ),
        onTap: () => Navigator.pop(context),
      ),
    );
  }

  /// 创建一个Popup的列表
  static Widget _buildListView(
    BuildContext context,
    List<String> titles, {
    double radius = 8,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    ItemTapCallback? onItemTap,
  }) {
    int index = 0;
    return Container(
      decoration: BoxDecoration(
        color: color ?? Colors.black38,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      margin: margin ?? EdgeInsets.symmetric(horizontal: 8),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: titles.map((title) {
          return TapLayout(
            padding: padding ?? EdgeInsets.symmetric(vertical: 8, horizontal: 32),
            child: Text(title, style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              if (onItemTap != null) {
                onItemTap(index++);
              }
            },
          );
        }).toList(),
      ),
    );
  }

  /// 创建自定义的Popup Widget
  Widget _buildCustomWidget(Widget child) {
    return Container(
      key: popupWindowKey,
      child: child,
    );
  }
}

/// 自定义的Popup跳转时的路由
class CustomPopupRoute extends PopupRoute {
  final Duration _duration = Duration(milliseconds: 100);
  Widget child;

  CustomPopupRoute({required this.child});

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
enum PopDirection {
  left,
  top,
  right,
  bottom,
}
