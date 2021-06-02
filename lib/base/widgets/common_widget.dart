import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// 数量标签
Widget badgeView({int count = -1}) {
  // 根据数量设置不同的宽度
  double width = count > 99
      ? 24
      : count > 9
          ? 20
          : count > 0
              ? 16
              : 8;
  // 根据数量设置显示文本
  String text = count > 99
      ? '99+'
      : count > 0
          ? '$count'
          : '';
  return Offstage(
    offstage: count < 0,
    child: Container(
      height: 15,
      width: width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: count >= 10 ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: count >= 10 ? BorderRadius.circular(8) : null,
        color: Colors.red,
      ),
      child: Text(text, style: TextStyle(color: Colors.white, fontSize: 8)),
    ),
  );
}

// 分割线
Widget divider({double height = 0.5, double left = 0, double right = 0, Color color = Colors.grey}) {
  return Divider(
    height: height,
    indent: left,
    endIndent: right,
    color: color,
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
