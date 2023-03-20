import 'theme/app_theme.dart';
import 'theme/black_theme.dart';
import 'theme/blue_accent_theme.dart';
import 'theme/blue_theme.dart';
import 'theme/cyan_theme.dart';
import 'theme/deep_orange_accent_theme.dart';
import 'theme/deep_purple_accent_theme.dart';
import 'theme/gray_theme.dart';
import 'theme/green_theme.dart';
import 'theme/orange_theme.dart';
import 'theme/pink_theme.dart';
import 'theme/purple_theme.dart';
import 'theme/red_theme.dart';
import 'theme/teal_theme.dart';

class C {
  static AppTheme getTheme(String key) {
    return _theme[key]!;
  }

  static List<String> getKeys() {
    return _theme.keys.map((e) => e).toList();
  }

  static final Map<String, AppTheme> _theme = {
    'gray': GrayTheme(),
    'blue': BlueTheme(),
    'blueAccent': BlueAccentTheme(),
    'cyan': CyanTheme(),
    'purple': PurpleTheme(),
    'deepPurpleAccent': DeepPurpleAccentTheme(),
    'deepOrange': DeepOrangeAccentTheme(),
    'green': GreenTheme(),
    'orange': OrangeTheme(),
    'pink': PinkTheme(),
    'red': RedTheme(),
    'teal': TealTheme(),
    'black': BlackTheme(),
  };
}
