import 'package:flutter_ui/application.dart';

///
/// Created by a0010 on 2023/5/8 11:25
///
class SortStudy {
  static void main() {
    List<People> list = [];
    list.add(People(age: 23, index: 1));
    list.add(People(age: 23, index: 6));
    list.add(People(age: 24, index: 1));
    list.add(People(age: 26, index: 6));
    list.add(People(age: 23, index: 3));
    list.add(People(age: 26, index: 5));
    list.add(People(age: 37, index: 5));
    list.add(People(age: 36, index: 5));
    list.add(People(age: 17, index: 5));

    /// item：age=17, index=5
    /// item：age=23, index=1
    /// item：age=23, index=3
    /// item：age=23, index=6
    /// item：age=24, index=1
    /// item：age=26, index=5
    /// item：age=26, index=6
    /// item：age=36, index=5
    /// item：age=37, index=5
    list.sort((a, b) {
      if (a.age != b.age) {
        return a.age.compareTo(b.age);
      }
      return a.index.compareTo(b.index);
    });

    for (var item in list) {
      Application().log('item：age=${item.age}, index=${item.index}');
    }
  }
}

class People {
  int age;
  int index;

  People({required this.age, required this.index});
}
