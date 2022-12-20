import 'package:flutter/material.dart';

Map<String, AppTheme> themeModel = {
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

class AppTheme {
  Color get primary => Colors.transparent;

  Color get primaryDark => Colors.transparent;

  Color get primaryLight => Colors.transparent;

  Color get secondary => Colors.transparent;

  Color get secondaryDark => Colors.transparent;

  Color get secondaryLight => Colors.transparent;

  Color get accent => Colors.transparent;

  Color get accentDark => Colors.transparent;

  Color get accentLight => Colors.transparent;

  Color get background => const Color(0XFFE0E1FF);

  Color get primaryBackground => const Color(0XFFE0E1FF);

  Color get secondaryBackground => const Color(0XFFE0E1FF);

  Color get divide => Colors.transparent;

  Color get divideDark => Colors.transparent;

  Color get divideLight => Colors.transparent;

  Color get primaryText => const Color(0XFF000000);

  Color get primaryTextDark => Colors.transparent;

  Color get primaryTextLight => Colors.transparent;

  Color get secondaryText => const Color(0XFF4F4F4F);

  Color get secondaryTextDark => Colors.transparent;

  Color get secondaryTextLight => Colors.transparent;

  Color get hintText => const Color(0XFFBDBDBD);

  Color get white => Colors.white;

  Color get black => Colors.black;
}

class GrayTheme extends AppTheme {
  @override
  Color get primary => Colors.grey;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.white;
}

class BlueTheme extends AppTheme {
  @override
  Color get primary => Colors.blue;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.white;

  @override
  Color get divide => Color(0xFFEFEFEF);
}

class BlueAccentTheme extends AppTheme {
  @override
  Color get primary => Colors.blueAccent;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.white;

  @override
  Color get divide => Color(0xFFEFEFEF);
}

class CyanTheme extends AppTheme {
  @override
  Color get primary => Colors.cyan;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.white;

  @override
  Color get divide => Color(0xFFEFEFEF);
}

class PurpleTheme extends AppTheme {
  @override
  Color get primary => Colors.purple;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.white;

  @override
  Color get divide => Color(0xFFEFEFEF);
}

class DeepPurpleAccentTheme extends AppTheme {
  @override
  Color get primary => Colors.deepPurpleAccent;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.white;

  @override
  Color get divide => Color(0xFFEFEFEF);
}

class DeepOrangeAccentTheme extends AppTheme {
  @override
  Color get primary => Colors.deepOrange;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.white;

  @override
  Color get divide => Color(0xFFEFEFEF);
}

class GreenTheme extends AppTheme {
  @override
  Color get primary => Colors.green;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.white;

  @override
  Color get divide => Color(0xFFEFEFEF);
}

class OrangeTheme extends AppTheme {
  @override
  Color get primary => Colors.orange;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.orangeAccent;

  @override
  Color get divide => Color(0xFFEFEFEF);
}

class PinkTheme extends AppTheme {
  @override
  Color get primary => Colors.pink;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.orangeAccent;

  @override
  Color get divide => Color(0xFFEFEFEF);
}

class RedTheme extends AppTheme {
  @override
  Color get primary => Colors.red;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.deepOrange;

  @override
  Color get divide => Color(0xFFEFEFEF);
}

class TealTheme extends AppTheme {
  @override
  Color get primary => Colors.teal;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.white;

  @override
  Color get divide => Color(0xFFEFEFEF);
}

class BlackTheme extends AppTheme {
  @override
  Color get primary => Colors.black;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.white;

  @override
  Color get divide => Color(0xFFEFEFEF);
}
