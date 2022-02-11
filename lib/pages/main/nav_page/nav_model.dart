import 'package:flutter/widgets.dart';
import 'package:flutter_ui/main.dart';
import 'package:provider/provider.dart';

class NavModel with ChangeNotifier {
  static NavModel get of => Provider.of<NavModel>(Application.context, listen: false);

  String _value = 'default';

  String get value => _value;

  void setValue(String value) {
    _value = value;
    notifyListeners();
  }
}
