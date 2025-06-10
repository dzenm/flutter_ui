import 'package:flutter/material.dart';

///
/// Created by a0010 on 2024/12/30 15:58
/// 标签类的通用组件
///

/// 徽章标签
/// BadgeTag(count: 10),
class BadgeTag extends StatelessWidget {
  final int count; // 展示的数量, 为0时不展示小红点和数量，为负数时展示小红点不展示数量
  final Color color; // 背景颜色
  final double fontSize; // 文本大小

  const BadgeTag({
    super.key,
    this.count = 0,
    this.color = Colors.red,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    // 当数量为于0，不展示
    if (count == 0) {
      return const SizedBox.shrink();
    }
    bool isOver100 = count > 99; // 数量为三位数
    bool isOver10 = 9 < count && count <= 99; // 数量为两位数
    bool isOver1 = 0 < count && count <= 9; // 数量为一位数
    bool isNegative = count < 0; // 负数

    String text = ''; // 数量
    BoxShape shape = BoxShape.rectangle;
    BorderRadius? borderRadius;
    EdgeInsetsGeometry? padding;
    if (isNegative) {
      shape = BoxShape.circle;
      padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 4);
    } else if (isOver1) {
      text = '$count';
      shape = BoxShape.circle;
      padding = EdgeInsets.symmetric(horizontal: fontSize / 2, vertical: 1);
    } else if (isOver10) {
      text = '$count';
      borderRadius = BorderRadius.circular(2 * fontSize);
      padding = EdgeInsets.symmetric(horizontal: fontSize / 2, vertical: 1);
    } else if (isOver100) {
      text = '99+';
      borderRadius = BorderRadius.circular(2 * fontSize);
      padding = EdgeInsets.symmetric(horizontal: fontSize / 2, vertical: 1);
    }
    return Container(
      padding: padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: shape, borderRadius: borderRadius, color: color),
      child: Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: fontSize),
      ),
    );
  }
}
