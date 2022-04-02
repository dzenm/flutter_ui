import 'package:flutter/widgets.dart';

class Item {
  int index;
  String? title;
  IconData? icon;
  bool selected;

  Item(this.index, {this.title, this.icon, this.selected = true});
}
