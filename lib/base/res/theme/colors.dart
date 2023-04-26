import 'package:flutter_ui/base/res/theme/dark_theme.dart';
import 'package:flutter_ui/base/res/theme/light_theme.dart';

import 'app_theme.dart';
import 'black_theme.dart';
import 'blue_accent_theme.dart';
import 'blue_theme.dart';
import 'cyan_theme.dart';
import 'deep_orange_accent_theme.dart';
import 'deep_purple_accent_theme.dart';
import 'gray_theme.dart';
import 'green_theme.dart';
import 'orange_theme.dart';
import 'pink_theme.dart';
import 'purple_theme.dart';
import 'red_theme.dart';
import 'teal_theme.dart';

class C {
  static AppThemeMode getMode(String name) {
    AppThemeMode mode = AppThemeMode.light;
    AppThemeMode.values.forEach((value) {
      if (value.name == name) mode = value;
    });
    return mode;
  }

  static AppTheme getTheme(AppThemeMode mode) {
    return _appTheme[mode]!;
  }

  static List<AppThemeMode> getThemeModes() {
    return _appTheme.keys.toList();
  }

  static final Map<AppThemeMode, AppTheme> _appTheme = {
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
