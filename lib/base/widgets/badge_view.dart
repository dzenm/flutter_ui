import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// 徽章标签
class BadgeView extends StatefulWidget {
  final int count;
  final Color color;

  BadgeView({
    this.count = -1,
    this.color = Colors.red,
  });

  @override
  State<StatefulWidget> createState() => _BadgeViewState();
}

class _BadgeViewState extends State<BadgeView> {
  @override
  Widget build(BuildContext context) {
    // 根据数量设置不同的宽度
    int count = widget.count;
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
          color: widget.color,
        ),
        child: Text(text, style: TextStyle(color: Colors.white, fontSize: 8)),
      ),
    );
  }
}
