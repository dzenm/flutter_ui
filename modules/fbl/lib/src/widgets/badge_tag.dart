import 'package:flutter/material.dart';

///
/// 徽章标签
/// BadgeTag(count: 10),
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
      return const SizedBox.shrink();
    }
    bool isOver100 = count > 99;
    bool isOver10 = count > 9;
    bool isOver1 = count > 0;
    bool isZero = count == 0;

    double width = 8; // 宽度
    double height = 8; // 高度
    String text = ''; // 数量
    BoxShape shape = BoxShape.rectangle;
    BorderRadius? borderRadius = BorderRadius.circular(8);
    if (isZero) {
      shape = BoxShape.circle;
      borderRadius = null;
    } else if (isOver1) {
      width = 16;
      height = 16;
      text = '$count';
      shape = BoxShape.circle;
      borderRadius = null;
    } else if (isOver10) {
      width = 20;
      text = '$count';
    } else if (isOver100) {
      width = 24;
      text = '99+';
    }
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: borderRadius,
        color: color,
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 8),
      ),
    );
  }
}
