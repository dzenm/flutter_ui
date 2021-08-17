import 'package:flutter/widgets.dart';
import 'package:flutter_ui/main.dart';
import 'package:provider/provider.dart';

class MeModel with ChangeNotifier {
  static MeModel get of => Provider.of<MeModel>(Application.context, listen: false);

  String _value = 'default';

  String get value => _value;

  void setValue(String value) {
    _value = value;
    notifyListeners();
  }
}
