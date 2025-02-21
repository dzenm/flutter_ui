import 'package:flutter/widgets.dart';

///
/// Created by a0010 on 2025/2/19 16:10
///
class ProviderModel extends InheritedNotifier<StudyProviderModel> {
  const ProviderModel({super.key, super.notifier, required super.child});

  // 定义一个便捷方法，方便子树中的widget获取共享数据
  static StudyProviderModel of(BuildContext context) => //
      context.dependOnInheritedWidgetOfExactType<ProviderModel>()!.notifier!;

  static StudyProviderModel read(BuildContext context) => //
      context.getInheritedWidgetOfExactType<ProviderModel>()!.notifier!;
}

class StudyProviderModel extends ChangeNotifier {
  int get value => _value;
  int _value = 18;

  void add() {
    _value++;
    notifyListeners();
  }

  void reset() {
    _value = 18;
    notifyListeners();
  }
}
