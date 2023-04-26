import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'local_model.dart';
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

////
//// Created by a0010 on 2023/1/30 15:15
////
class AppTheme {
  /// 获取颜色
  static AppTheme of(BuildContext context, {bool listen = true}) {
    return Provider.of<LocalModel>(context, listen: listen).appTheme;
  }

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


  /// 根据颜色命名
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

  /// 根据功能命名(整体)
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
  Color get hintText => white300; // 提示文本颜色

  /// 根据功能命名(局部)
  Color get appbarForeground => white; // appbar前景颜色
  Color get appbarColor => white; // appbar背景颜色
  Color get bottomBarColor => white; // bottomBar背景颜色

  ///       Brightness brightness, /// 应用整体主题的亮度。用于按钮之类的小部件，以确定在不使用主色或强调色时选择什么颜色。
  /// 	  MaterialColor primarySwatch,/// 定义一个单一的颜色以及十个色度的色块。
  /// 	  Color primaryColor, /// 应用程序主要部分的背景颜色(toolbars、tab bars 等)
  /// 	  Brightness primaryColorBrightness, /// primaryColor的亮度。用于确定文本的颜色和放置在主颜色之上的图标(例如工具栏文本)。
  /// 	  Color primaryColorLight, /// primaryColor的浅色版
  /// 	  Color primaryColorDark, /// primaryColor的深色版
  /// 	  Color accentColor, /// 小部件的前景色(旋钮、文本、覆盖边缘效果等)。
  /// 	  Brightness accentColorBrightness, /// accentColor的亮度。
  /// 	  Color canvasColor, ///  MaterialType.canvas 的默认颜色
  /// 	  Color scaffoldBackgroundColor, /// Scaffold的默认颜色。典型Material应用程序或应用程序内页面的背景颜色。
  /// 	  Color bottomAppBarColor, /// BottomAppBar的默认颜色
  /// 	  Color cardColor, /// Card的颜色
  /// 	  Color dividerColor, /// Divider和PopupMenuDivider的颜色，也用于ListTile之间、DataTable的行之间等。
  /// 	  Color highlightColor, /// 选中在泼墨动画期间使用的突出显示颜色，或用于指示菜单中的项。
  /// 	  Color splashColor,  /// 墨水飞溅的颜色。InkWell
  /// 	  InteractiveInkFeatureFactory splashFactory, /// 定义由InkWell和InkResponse反应产生的墨溅的外观。
  /// 	  Color selectedRowColor, /// 用于突出显示选定行的颜色。
  /// 	  Color unselectedWidgetColor, /// 用于处于非活动(但已启用)状态的小部件的颜色。例如，未选中的复选框。通常与accentColor形成对比。也看到disabledColor。
  /// 	  Color disabledColor, /// 禁用状态下部件的颜色，无论其当前状态如何。例如，一个禁用的复选框(可以选中或未选中)。
  /// 	  Color buttonColor, /// RaisedButton按钮中使用的Material 的默认填充颜色。
  /// 	  ButtonThemeData buttonTheme, /// 定义按钮部件的默认配置，如RaisedButton和FlatButton。
  /// 	  Color secondaryHeaderColor, /// 选定行时PaginatedDataTable标题的颜色。
  /// 	  Color textSelectionColor, /// 文本框中文本选择的颜色，如TextField
  /// 	  Color cursorColor, /// 文本框中光标的颜色，如TextField
  /// 	  Color textSelectionHandleColor,  /// 用于调整当前选定的文本部分的句柄的颜色。
  /// 	  Color backgroundColor, /// 与主色形成对比的颜色，例如用作进度条的剩余部分。
  /// 	  Color dialogBackgroundColor, /// Dialog 元素的背景颜色
  /// 	  Color indicatorColor, /// 选项卡中选定的选项卡指示器的颜色。
  /// 	  Color hintColor, /// 用于提示文本或占位符文本的颜色，例如在TextField中。
  /// 	  Color errorColor, /// 用于输入验证错误的颜色，例如在TextField中
  /// 	  Color toggleableActiveColor, /// 用于突出显示Switch、Radio和Checkbox等可切换小部件的活动状态的颜色。
  /// 	  String fontFamily, /// 文本字体
  /// 	  TextTheme textTheme, /// 文本的颜色与卡片和画布的颜色形成对比。
  /// 	  TextTheme primaryTextTheme, /// 与primaryColor形成对比的文本主题
  /// 	  TextTheme accentTextTheme, /// 与accentColor形成对比的文本主题。
  /// 	  InputDecorationTheme inputDecorationTheme, /// 基于这个主题的 InputDecorator、TextField和TextFormField的默认InputDecoration值。
  /// 	  IconThemeData iconTheme, /// 与卡片和画布颜色形成对比的图标主题
  /// 	  IconThemeData primaryIconTheme, /// 与primaryColor形成对比的图标主题
  /// 	  IconThemeData accentIconTheme, /// 与accentColor形成对比的图标主题。
  /// 	  SliderThemeData sliderTheme,  /// 用于呈现Slider的颜色和形状
  /// 	  TabBarTheme tabBarTheme, /// 用于自定义选项卡栏指示器的大小、形状和颜色的主题。
  /// 	  CardTheme cardTheme, /// Card的颜色和样式
  /// 	  ChipThemeData chipTheme, /// Chip的颜色和样式
  /// 	  TargetPlatform platform,
  /// 	  MaterialTapTargetSize materialTapTargetSize, /// 配置某些Material部件的命中测试大小
  /// 	  PageTransitionsTheme pageTransitionsTheme,
  /// 	  AppBarTheme appBarTheme, /// 用于自定义Appbar的颜色、高度、亮度、iconTheme和textTheme的主题。
  /// 	  BottomAppBarTheme bottomAppBarTheme, /// 自定义BottomAppBar的形状、高度和颜色的主题。
  /// 	  ColorScheme colorScheme, /// 拥有13种颜色，可用于配置大多数组件的颜色。
  /// 	  DialogTheme dialogTheme, /// 自定义Dialog的主题形状
  /// 	  Typography typography, /// 用于配置TextTheme、primaryTextTheme和accentTextTheme的颜色和几何TextTheme值。
  /// 	  CupertinoThemeData cupertinoOverrideTheme
}

/// APP主题模式
enum AppThemeMode {
  light('light'),
  dark('dark'),
  gray('gray'),
  blue('blue'),
  blueAccent('blueAccent'),
  cyan('cyan'),
  purple('purple'),
  deepPurpleAccent('deepPurpleAccent'),
  deepOrange('deepOrange'),
  green('green'),
  orange('orange'),
  pink('pink'),
  red('red'),
  teal('teal'),
  black('black');

  /// 可以自定义枚举对应的值
  final String name;

  const AppThemeMode(this.name);
}
