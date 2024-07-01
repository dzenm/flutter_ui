import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/4/26 15:45
///
class UnreadTag extends StatelessWidget {
  final int count; // 为-1时展示小圆点不展示数量，为0时不展示布局，小于100时展示具体数量，大于等于100时展示99+

  const UnreadTag({super.key, this.count = 0});

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const SizedBox.shrink();
    }
    bool isMute = count == -1;
    double height = isMute ? 9 : 15;
    double width = isMute
        ? 9
        : count >= 100
            ? 25
            : count >= 10
                ? 20
                : 15;
    String text = isMute
        ? ''
        : count >= 100
            ? '99+'
            : '$count';
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: count >= 10 ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: count >= 10 ? BorderRadius.circular(50) : null,
        color: Colors.red,
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
        ),
      ),
    );
  }
}
