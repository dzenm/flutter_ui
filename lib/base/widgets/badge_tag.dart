import 'package:flutter/material.dart';

// 徽章标签
class BadgeTag extends StatelessWidget {
  final int count; // 展示的数量, 为0时展示小红点不展示数量，为-1时不展示
  final Color color; // 背景颜色

  const BadgeTag({
    super.key,
    this.count = -1,
    this.color = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    // 当数量小于0，不展示
    if (count < 0) {
      return Container();
    }
    bool isOver100 = count > 99;
    bool isOver10 = count > 9;
    bool isOver1 = count > 0;
    // 根据数量设置不同的大小
    double height = isOver1 ? 16 : 8;
    double width = isOver100
        ? 24
        : isOver10
            ? 20
            : isOver1
                ? 16
                : 8;
    // 根据数量设置显示文本
    String text = isOver100
        ? '99+'
        : isOver1
            ? '$count'
            : '';
    BoxShape shape = isOver10 ? BoxShape.rectangle : BoxShape.circle;
    BorderRadius? borderRadius = isOver10 ? BorderRadius.circular(8) : null;
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: borderRadius,
        color: color,
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 8)),
    );
  }
}
