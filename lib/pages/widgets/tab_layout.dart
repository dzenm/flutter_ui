import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/12/25 14:06
///
class TabLayout extends StatelessWidget {
  final List<String> tabs;
  final int selectedTab;
  final Color? tabColor;
  final double? height;
  final double? width;
  final double marginTop;
  final ValueChanged<int>? onSelected;

  const TabLayout({
    super.key,
    required this.tabs,
    this.selectedTab = 0,
    this.tabColor,
    this.height,
    this.width,
    this.marginTop = 10,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      margin: EdgeInsets.only(top: marginTop),
      width: width ?? MediaQuery.of(context).size.width,
      height: height ?? 45,
      color: tabColor ?? Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: tabs.map((tab) => Expanded(child: _buildTab(tab))).toList(),
      ),
    );
  }

  Widget _buildTab(String tab) {
    bool isSelected = tabs[selectedTab] != tab;
    Color borderColor = isSelected ? Colors.transparent : Colors.blue;
    double borderWidth = isSelected ? 0 : 2;
    Color color = isSelected ? Colors.grey : Colors.blue;
    return GestureDetector(
      onTap: () {
        int index = tabs.indexOf(tab);
        if (selectedTab != index) {
          onSelected!(index);
        }
      },
      child: Container(
        height: 45,
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: borderColor, width: borderWidth, style: BorderStyle.solid),
            ),
            color: Colors.transparent,
          ),
          child: CenterText(
            tab,
            style: TextStyle(fontSize: 16.0, color: color),
          ),
        ),
      ),
    );
  }
}
