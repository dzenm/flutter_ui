import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// 分割线
Widget divider({
  bool isVertical = false,
  double height = 0.5,
  double left = 0,
  double right = 0,
  double width = 0,
  Color color = Colors.black12,
}) {
  return Container(
    color: color,
    child: isVertical
        ? SizedBox()
        : Divider(
            height: height,
            indent: left,
            endIndent: right,
            color: Colors.transparent,
          ),
  );
}

Widget? leadingView({bool isLight = true}) {
  return BackButton(color: brightnessTheme(isLight: isLight));
}

Color brightnessTheme({bool isLight = true}) => isLight ? Colors.white : Colors.black87;

// 标题
Widget titleView(String title, {double left = 8, double top = 8, double right = 8, double bottom = 8}) {
  return Container(
    padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
    child: Row(children: [Expanded(child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))]),
  );
}

// 内容
Widget multipleTextView(String msg) {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.all(Radius.circular(8))),
    child: Row(
      children: [Expanded(child: Text(msg))],
    ),
  );
}
