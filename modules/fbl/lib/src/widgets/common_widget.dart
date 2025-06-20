import 'package:flutter/material.dart';

class CommonWidget {

  /// 标题
  static Widget titleView(
    String title, {
    double left = 8,
    double top = 8,
    double right = 8,
    double bottom = 8,
  }) {
    return Container(
      padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom),
      child: Row(children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ]),
    );
  }

  /// 内容
  static Widget multipleTextView(String msg) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(children: [
        Expanded(child: Text(msg)),
      ]),
    );
  }

  /// 默认的阴影
  static List<BoxShadow> defaultShadows() {
    return [
      const BoxShadow(
        offset: Offset(0, 1),
        blurRadius: 10.0,
        spreadRadius: 0.0,
        color: Color(0x0D000000),
      ),
      const BoxShadow(
        offset: Offset(0, 1),
        blurRadius: 4.0,
        spreadRadius: 0.0,
        color: Color(0x14000000),
      ),
    ];
  }
}
