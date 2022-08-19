import 'package:flutter/widgets.dart';
import 'package:flutter_ui/main.dart';
import 'package:provider/provider.dart';

class MeModel with ChangeNotifier {
  static MeModel get of => Provider.of<MeModel>(Application.context, listen: false);

  List<Person> persons = [Person('dinzhenyan', 24, 'JiangSu')];

  void updatePerson(int index, Person person) {
    persons[index] = person;
    notifyListeners();
  }
}

class Person {
  String? name;
  int? age;
  String? address;

  Person(this.name, this.age, this.address);
}
