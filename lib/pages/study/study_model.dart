import 'dart:math';

import 'package:flutter/material.dart';

import 'components/chat/chat_model.dart';

///
/// Created by a0010 on 2022/11/3 16:14
///
class StudyModel with ChangeNotifier {
  String _value = 'default';

  String get value => _value;

  void setValue(String value) {
    _value = value;
    notifyListeners();
  }

  String? _username = 'yuadi';

  String? get username => _username;

  set username(String? username) {
    _username = username;
    notifyListeners();
  }

  final List<User> _users = [];

  List<User> get users => List.generate(_users.length, (index) => _users[index]);

  /// 初始化数据
  Future<void> init() async {
    _users.add(User(id: 1, username: '张三', sex: 0, age: 26, address: '江苏省苏州市相城区', phone: '17601487212'));
    _users.add(User(id: 2, username: '李四', sex: 1, age: 32, address: '江西省赣州市赣县区', phone: '15102347891'));
    _users.add(User(id: 3, username: '王五', sex: 0, age: 23, address: '江苏省南京市玄武区', phone: '13799876651'));
    _users.add(User(id: 4, username: '赵六', sex: 1, age: 29, address: '安徽省合肥市蜀山区', phone: '18177653451'));
  }

  User? getUser(int? id) {
    int index = _users.indexWhere((u) => u.id == id);
    if (index == -1) return null;
    return _users[index];
  }

  void updateUser(User? user) {
    if (user == null) return;
    int index = _users.indexWhere((u) => u.id == user.id);
    if (index == -1) {
      _users.add(user);
    } else {
      _users[index] = user;
    }
    notifyListeners();
  }

  void removeUser(int? id) {
    int index = _users.indexWhere((u) => u.id == id);
    if (index >= 0) {
      _users.removeAt(index);
      notifyListeners();
    }
  }

  List<ChatModel> _chatModels = [];
  List<ChatModel> get chatModels => _chatModels;

  void initModels() async {
    _chatModels = ChatModel.createChatModels();
    notifyListeners();
  }

  void insert() async {
    await Future.delayed(const Duration(seconds: 2));
    List<ChatModel> list = List.generate(5, (index) => ChatModel.createChatModel());
    for (var item in list) {
      _chatModels.insert(0, item);
    }
    notifyListeners();
  }

  /// 清空数据
  void clear() {
    _users.clear();
    notifyListeners();
  }
}

class User {
  int? id;
  String? username;
  int? sex;
  int? age;
  String? address;
  String? phone;

  User({
    this.id,
    this.username,
    this.sex,
    this.age,
    this.address,
    this.phone,
  });

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    sex = json['sex'];
    age = json['age'];
    address = json['address'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'sex': sex,
        'age': age,
        'address': address,
        'phone': phone,
      };

  void merge(User user) {
    if (user.username != null && username != user.username) {
      username = user.username;
    }
    if (user.sex != null && sex != user.sex) {
      sex = user.sex;
    }
    if (user.age != null && age != user.age) {
      age = user.age;
    }
    if (user.address != null && address != user.address) {
      address = user.address;
    }
    if (user.phone != null && phone != user.phone) {
      phone = user.phone;
    }
  }
}
