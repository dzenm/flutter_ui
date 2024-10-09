import 'package:flutter/material.dart';

import 'tap_layout.dart';

///
/// Created by a0010 on 2023/11/23 11:12
///
/// An indicator showing the currently selected page of a PageController
class DotsIndicator extends AnimatedWidget {
  const DotsIndicator({
    super.key,
    required this.controller,
    this.itemCount = 0,
    required this.onPageSelected,
    this.color = Colors.white,
    this.dotsType = DotsType.text,
    this.size = 8,
    this.icons,
  }) : super(listenable: controller);

  /// The PageController that this DotsIndicator is representing.
  final PageController controller;

  /// The number of items managed by the PageController
  final int itemCount;

  /// Called when a dot is tapped
  final ValueChanged<int> onPageSelected;

  /// The color of the dots.
  /// Defaults to `Colors.white`.
  final Color color;

  /// Dots展示的布局样式 @see [DotsType]
  final DotsType dotsType;

  /// Dots布局的大小
  final double size;

  /// 展示Dots的图标
  final List<Widget>? icons;

  @override
  Widget build(BuildContext context) {
    double page = controller.hasClients ? controller.page ?? 0 : 0;
    int selectedIndex = page.round();
    switch (dotsType) {
      case DotsType.dot:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(itemCount, (index) => _buildDot(index == selectedIndex)),
        );
      case DotsType.text:
        return _buildText(selectedIndex + 1);
      case DotsType.icon:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List<Widget>.generate(itemCount, (index) => _buildIconTitle(index, selectedIndex)),
        );
    }
  }

  Widget _buildDot(bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3.0),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.grey : Colors.white,
          border: Border.all(color: Colors.grey, width: 1),
        ),
      ),
    );
  }

  Widget _buildText(int index) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 3, bottom: 3),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10)),
        color: Colors.grey.withOpacity(0.7),
      ),
      child: Text('$index / $itemCount', style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildIconTitle(int index, int selectedIndex) {
    bool isSelected = index == selectedIndex;
    return TapLayout(
      width: 36,
      height: 36,
      foreground: Colors.transparent,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(4),
      borderRadius: BorderRadius.circular(4),
      background: isSelected ? Colors.grey.shade300 : null,
      onTap: () => onPageSelected(index),
      child: icons![index],
    );
  }
}

/// 图标展示的样式
enum DotsType {
  dot,
  text,
  icon;
}
