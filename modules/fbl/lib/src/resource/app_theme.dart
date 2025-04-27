import 'package:flutter/material.dart';

import 'theme/black_theme.dart';
import 'theme/blue_accent_theme.dart';
import 'theme/blue_theme.dart';
import 'theme/cyan_theme.dart';
import 'theme/dark_theme.dart';
import 'theme/deep_orange_accent_theme.dart';
import 'theme/deep_purple_accent_theme.dart';
import 'theme/gray_theme.dart';
import 'theme/green_theme.dart';
import 'theme/light_theme.dart';
import 'theme/orange_theme.dart';
import 'theme/pink_theme.dart';
import 'theme/purple_theme.dart';
import 'theme/red_theme.dart';
import 'theme/teal_theme.dart';

///
/// Created by a0010 on 2023/1/30 15:15
///
abstract class AppTheme with _BaseColorMixin, _AppColorMixin {
  static final Map<AppThemeMode, AppTheme> appTheme = {
    AppThemeMode.light: LightTheme(),
    AppThemeMode.dark: DarkTheme(),
    AppThemeMode.gray: GrayTheme(),
    AppThemeMode.blue: BlueTheme(),
    AppThemeMode.blueAccent: BlueAccentTheme(),
    AppThemeMode.cyan: CyanTheme(),
    AppThemeMode.purple: PurpleTheme(),
    AppThemeMode.deepPurpleAccent: DeepPurpleAccentTheme(),
    AppThemeMode.deepOrange: DeepOrangeAccentTheme(),
    AppThemeMode.green: GreenTheme(),
    AppThemeMode.orange: OrangeTheme(),
    AppThemeMode.pink: PinkTheme(),
    AppThemeMode.red: RedTheme(),
    AppThemeMode.teal: TealTheme(),
    AppThemeMode.black: BlackTheme(),
  };
}

/// 按颜色命名的颜色代码，在此处增加按颜色命名的颜色代码
abstract mixin class _BaseColorMixin {
  ///================================ 根据颜色命名 ================================
  /// 由白到黑
  Color get black50 => const Color(0xFFFAFAFA); // 5%
  Color get black100 => const Color(0xFFF5F5F5); // 10%
  Color get black150 => const Color(0xFFEFEFEF); // 15%
  Color get black200 => const Color(0xFFEEEEEE); // 20%
  Color get black300 => const Color(0xFFE0E0E0); // 30%
  Color get black400 => const Color(0xFFBDBDBD); // 40%
  Color get black500 => const Color(0xFF9E9E9E); // 50%
  Color get black600 => const Color(0xFF757575); // 60%
  Color get black700 => const Color(0xFF616161); // 70%
  Color get black800 => const Color(0xFF424242); // 80%
  Color get black900 => const Color(0xFF212121); // 90%

  /// 纯黑系(按百分比)
  Color get black120 => const Color(0x1F000000); // 纯黑的 12% #e0e0e0
  Color get black260 => const Color(0x42000000); // 纯黑的 26% #BDBDBD
  Color get black380 => const Color(0x61000000); // 纯黑的 38% #757575
  Color get black450 => const Color(0x73000000); // 纯黑的 45% #9E9E9E
  Color get black540 => const Color(0x8A000000); // 纯黑的 54% #757575
  Color get black870 => const Color(0xDE000000); // 纯黑的 87% #212121
  Color get black => Colors.black; // 纯黑

  /// 纯白系(按百分比)
  Color get white120 => const Color(0x1FFFFFFF); // 纯白的 12% #e0e0e0
  Color get white260 => const Color(0x42FFFFFF); // 纯白的 26% #BDBDBD
  Color get white380 => const Color(0x61FFFFFF); // 纯白的 38% #BDBDBD
  Color get white450 => const Color(0x73FFFFFF); // 纯白的 45% #9E9E9E
  Color get white540 => const Color(0x8AFFFFFF); // 纯白的 54% #757575
  Color get white870 => const Color(0xDEFFFFFF); // 纯白的 87% #212121
  Color get white => Colors.white; // 纯白

  /// 其他单独的颜色
  Color get transparent => Colors.transparent; // 透明色
  Color get red => Colors.red; // 红色
  Color get blue => Colors.blue; // 蓝色
  Color get green => Colors.green; // 绿色
  Color get yellow => Colors.yellow; // 黄色
  Color get pink => Colors.pink; // 粉红色
  Color get amber => Colors.amber; // 琥珀色
  Color get brown => Colors.brown; // 棕色
  Color get cyan => Colors.cyan; // 青色
  Color get grey => Colors.grey; // 灰色
  Color get lime => Colors.lime; // 柠檬色
  Color get teal => Colors.teal; // 青色
  Color get orange => Colors.orange; // 橘色

  /// 默认颜色值
  Color get purple700 => const Color(0xFF3700B3); // default dark primary color
  Color get purple700Foreground => const Color(0x553700B3); // default dark primary color，添加透明度
  Color get purple500 => const Color(0xFF6200EE); // default primary color
  Color get purple500Foreground => const Color(0x556200EE); // default primary color，添加透明度
  Color get purple200 => const Color(0xFFBB86FC); // default light primary color
  Color get purple200Foreground => const Color(0x55BB86FC); // default light primary color，添加透明度
  Color get teal200 => const Color(0xFF03DAC5); // default accent color
  Color get teal200Foreground => const Color(0x5503DAC5); // default accent color，添加透明度

  /// 百分比：0% ，  十六进制值：00
  /// 百分比：1% ，  十六进制值：03
  /// 百分比：2% ，  十六进制值：05
  /// 百分比：3% ，  十六进制值：08
  /// 百分比：4% ，  十六进制值：0A
  /// 百分比：5% ，  十六进制值：0D
  /// 百分比：6% ，  十六进制值：0F
  /// 百分比：7% ，  十六进制值：12
  /// 百分比：8% ，  十六进制值：14
  /// 百分比：9% ，  十六进制值：17
  /// 百分比：10% ，  十六进制值：1A
  /// 百分比：11% ，  十六进制值：1C
  /// 百分比：12% ，  十六进制值：1F
  /// 百分比：13% ，  十六进制值：21
  /// 百分比：14% ，  十六进制值：24
  /// 百分比：15% ，  十六进制值：26
  /// 百分比：16% ，  十六进制值：29
  /// 百分比：17% ，  十六进制值：2B
  /// 百分比：18% ，  十六进制值：2E
  /// 百分比：19% ，  十六进制值：30
  /// 百分比：20% ，  十六进制值：33
  /// 百分比：21% ，  十六进制值：36
  /// 百分比：22% ，  十六进制值：38
  /// 百分比：23% ，  十六进制值：3B
  /// 百分比：24% ，  十六进制值：3D
  /// 百分比：25% ，  十六进制值：40
  /// 百分比：26% ，  十六进制值：42
  /// 百分比：27% ，  十六进制值：45
  /// 百分比：28% ，  十六进制值：47
  /// 百分比：29% ，  十六进制值：4A
  /// 百分比：30% ，  十六进制值：4D
  /// 百分比：31% ，  十六进制值：4F
  /// 百分比：32% ，  十六进制值：52
  /// 百分比：33% ，  十六进制值：54
  /// 百分比：34% ，  十六进制值：57
  /// 百分比：35% ，  十六进制值：59
  /// 百分比：36% ，  十六进制值：5C
  /// 百分比：37% ，  十六进制值：5E
  /// 百分比：38% ，  十六进制值：61
  /// 百分比：39% ，  十六进制值：63
  /// 百分比：40% ，  十六进制值：66
  /// 百分比：41% ，  十六进制值：69
  /// 百分比：42% ，  十六进制值：6B
  /// 百分比：43% ，  十六进制值：6E
  /// 百分比：44% ，  十六进制值：70
  /// 百分比：45% ，  十六进制值：73
  /// 百分比：46% ，  十六进制值：75
  /// 百分比：47% ，  十六进制值：78
  /// 百分比：48% ，  十六进制值：7A
  /// 百分比：49% ，  十六进制值：7D
  /// 百分比：50% ，  十六进制值：80
  /// 百分比：51% ，  十六进制值：82
  /// 百分比：52% ，  十六进制值：85
  /// 百分比：53% ，  十六进制值：87
  /// 百分比：54% ，  十六进制值：8A
  /// 百分比：55% ，  十六进制值：8C
  /// 百分比：56% ，  十六进制值：8F
  /// 百分比：57% ，  十六进制值：91
  /// 百分比：58% ，  十六进制值：94
  /// 百分比：59% ，  十六进制值：96
  /// 百分比：60% ，  十六进制值：99
  /// 百分比：61% ，  十六进制值：9C
  /// 百分比：62% ，  十六进制值：9E
  /// 百分比：63% ，  十六进制值：A1
  /// 百分比：64% ，  十六进制值：A3
  /// 百分比：65% ，  十六进制值：A6
  /// 百分比：66% ，  十六进制值：A8
  /// 百分比：67% ，  十六进制值：AB
  /// 百分比：68% ，  十六进制值：AD
  /// 百分比：69% ，  十六进制值：B0
  /// 百分比：70% ，  十六进制值：B3
  /// 百分比：71% ，  十六进制值：B5
  /// 百分比：72% ，  十六进制值：B8
  /// 百分比：73% ，  十六进制值：BA
  /// 百分比：74% ，  十六进制值：BD
  /// 百分比：75% ，  十六进制值：BF
  /// 百分比：76% ，  十六进制值：C2
  /// 百分比：77% ，  十六进制值：C4
  /// 百分比：78% ，  十六进制值：C7
  /// 百分比：79% ，  十六进制值：C9
  /// 百分比：80% ，  十六进制值：CC
  /// 百分比：81% ，  十六进制值：CF
  /// 百分比：82% ，  十六进制值：D1
  /// 百分比：83% ，  十六进制值：D4
  /// 百分比：84% ，  十六进制值：D6
  /// 百分比：85% ，  十六进制值：D9
  /// 百分比：86% ，  十六进制值：DB
  /// 百分比：87% ，  十六进制值：DE
  /// 百分比：88% ，  十六进制值：E0
  /// 百分比：89% ，  十六进制值：E3
  /// 百分比：90% ，  十六进制值：E6
  /// 百分比：91% ，  十六进制值：E8
  /// 百分比：92% ，  十六进制值：EB
  /// 百分比：93% ，  十六进制值：ED
  /// 百分比：94% ，  十六进制值：F0
  /// 百分比：95% ，  十六进制值：F2
  /// 百分比：96% ，  十六进制值：F5
  /// 百分比：97% ，  十六进制值：F7
  /// 百分比：98% ，  十六进制值：FA
  /// 百分比：99% ，  十六进制值：FC
  /// 百分比：100% ，  十六进制值：FF
}

/// APP相关的颜色，在此处增加自定义的功能颜色
abstract mixin class _AppColorMixin implements _BaseColorMixin  {
  ///================================ 根据功能命名(整体) ================================
  Color get primaryDark => purple700; // 主要颜色(深色)
  Color get primary => purple500; // 主要颜色
  Color get primaryLight => purple200; // 主要颜色(浅色)
  Color get secondary => purple500; // 次要颜色
  Color get accent => teal200; // 主要颜色的对比颜色
  Color get button => purple500; // 按钮颜色
  Color get disableButton => purple200; // 禁用的按钮颜色
  Color get selected => purple500; // 选中的颜色
  Color get unselected => purple200; // 未选中的颜色
  Color get icon => white; // 图标颜色(浅色white, 深色black900)
  Color get text => white; // 文本颜色(浅色white, 深色black900)
  Color get signText => blue; // 标记提醒文本颜色
  Color get background => black50; // 普通背景色
  Color get foreground => black50; // 普通前景色
  Color get divide => black300; // 分割线颜色
  Color get hint => black400; // 提示颜色
  Color get primaryText => black900; // 主要文本颜色
  Color get secondaryText => black600; // 次要文本颜色
  Color get accentText => blue; // 主要文本颜色的对比文本颜色
  Color get hintText => black300; // 提示文本颜色

  ///================================ 根据功能命名(局部) ================================
  Color get statusBar => purple700; // appbar背景颜色
  Color get appbar => purple700; // appbar背景颜色
  Color get bottomBar => white; // bottomBar背景颜色
  Color get cardBackgroundLight => black50; // 卡片背景颜色(浅色)
  Color get cardBackground => black100; // 卡片背景颜色
  Color get cardBackgroundDark => black150; // 卡片背景颜色(深色)
  Color get collect => red; // 收藏的颜色
  Color get notCollect => black400; // 未收藏的颜色
  Color get checked => blue; // 勾选(CheckBox)的颜色
  Color get unchecked => black400; // 未勾选(CheckBox)的颜色
}

/// APP主题模式
enum AppThemeMode {
  light,
  dark,
  gray,
  blue,
  blueAccent,
  cyan,
  purple,
  deepPurpleAccent,
  deepOrange,
  green,
  orange,
  pink,
  red,
  teal,
  black;
}