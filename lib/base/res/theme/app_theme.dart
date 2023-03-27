import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/1/30 15:15
///
class AppTheme {
  // 根据颜色命名
  Color get white50 => Color(0xFAFAFA); // 纯白的 5%
  Color get white100 => Color(0xF5F5F5); // 纯白的 10%
  Color get white150 => Color(0xEFEFEF); // 纯白的 15%
  Color get white200 => Color(0xEEEEEE); // 纯白的 20%
  Color get white300 => Color(0xE0E0E0); // 纯白的 30%
  Color get white400 => Color(0xBDBDBD); // 纯白的 40%
  Color get white500 => Color(0x9E9E9E); // 纯白的 50%
  Color get white600 => Color(0x757575); // 纯白的 60%
  Color get white700 => Color(0x616161); // 纯白的 70%
  Color get white800 => Color(0x424242); // 纯白的 80%
  Color get white900 => Color(0x212121); // 纯白的 90%

  Color get black12 => Color(0xFFE0E0E0); // 纯黑的 12% #e0e0e0
  Color get black26 => Color(0x43000000); // 纯黑的 26% #BDBDBD
  Color get black54 => Color(0x8A000000); // 纯黑的 54% #757575
  Color get black87 => Color(0xDE000000); // 纯黑的 87% #212121
  Color get black => Colors.black; // 纯黑

  Color get white12 => Color(0x1EFFFFFF); // 纯白的 12% #e0e0e0
  Color get white26 => Color(0x80FFFFFF); // 纯黑的 26% #BDBDBD
  Color get white54 => Color(0x80FFFFFF); // 纯黑的 54% #757575
  Color get white87 => Color(0xB2FFFFFF); // 纯黑的 87% #212121
  Color get white => Colors.white; // 纯白

  // 根据功能命名
  Color get primary => white; // 主要颜色
  Color get secondary => white; // 次要颜色
  Color get accent => white; // 主要颜色的对比颜色
  Color get button => white; // 按钮颜色
  Color get selected => white; // 选中的颜色
  Color get disableButton => white; // 禁用的按钮颜色
  Color get background => white50; // 普通背景色
  Color get divide => white300; // 分割线颜色
  Color get hint => white400; // 提示颜色
  Color get primaryText => white900; // 主要文本颜色
  Color get secondaryText => white600; // 次要文本颜色

  Color get toolbarForeground => white; // toolbar前景颜色
  Color get toolbarBackground => white; // toolbar背景颜色
  Color get bottomNavigationBar => white; // bottomNavigationBar背景颜色
}
