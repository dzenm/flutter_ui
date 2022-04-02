import 'package:flutter/widgets.dart';
import 'package:flutter_ui/main.dart';
import 'package:provider/provider.dart';

class MeModel with ChangeNotifier {
  static MeModel get of => Provider.of<MeModel>(Application.context, listen: false);

  Map<String, dynamic> map = {
    'parent1': 'parent init',
    'parent2': 'parent init',
    'child1': 'child1 init',
    'child2': 'child2 init',
  };

  String get value => map['parent1'];

  void setValue(String value) {
    map['parent1'] = value;
    notifyListeners();
  }

  String get childValue => map['child1'];

  void setChildValue(String value) {
    map['child1'] = value;
    notifyListeners();
  }

  Map<String, dynamic> get entity => map;

  void setMap(Map<String, dynamic> data) {
    map = data;
    notifyListeners();
  }
}
