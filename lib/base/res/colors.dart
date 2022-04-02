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

  Color get secondary => Colors.transparent;

  Color get background => Colors.transparent;
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
}

class BlueAccentTheme extends AppTheme {
  @override
  Color get primary => Colors.blueAccent;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.white;
}

class CyanTheme extends AppTheme {
  @override
  Color get primary => Colors.cyan;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.white;
}

class PurpleTheme extends AppTheme {
  @override
  Color get primary => Colors.purple;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.white;
}

class DeepPurpleAccentTheme extends AppTheme {
  @override
  Color get primary => Colors.deepPurpleAccent;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.white;
}

class DeepOrangeAccentTheme extends AppTheme {
  @override
  Color get primary => Colors.deepOrange;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.white;
}

class GreenTheme extends AppTheme {
  @override
  Color get primary => Colors.green;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.white;
}

class OrangeTheme extends AppTheme {
  @override
  Color get primary => Colors.orange;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.orangeAccent;
}

class PinkTheme extends AppTheme {
  @override
  Color get primary => Colors.pink;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.orangeAccent;
}

class RedTheme extends AppTheme {
  @override
  Color get primary => Colors.red;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.deepOrange;
}

class TealTheme extends AppTheme {
  @override
  Color get primary => Colors.teal;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.white;
}

class BlackTheme extends AppTheme {
  @override
  Color get primary => Colors.black;

  @override
  Color get secondary => Colors.transparent;

  @override
  Color get background => Colors.white;
}
