import 'package:flutter/widgets.dart';

class MeModel with ChangeNotifier {
  List<Person> persons = [Person('dinzhenyan', 24, 'JiangSu')];

  /// 初始化数据
  Future<void> init() async {
    notifyListeners();
  }

  void updatePerson(int index, Person person) {
    persons[index] = person;
    notifyListeners();
  }

  String _ip = 'IP';

  String get ip => _ip;

  void updateIP(String ip) {
    _ip = ip;
    notifyListeners();
  }

  /// 清空数据
  void clear() {
    notifyListeners();
  }
}

class Person {
  String? name;
  int? age;
  String? address;

  Person(this.name, this.age, this.address);
}
