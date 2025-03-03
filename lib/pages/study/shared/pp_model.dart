import 'package:flutter/widgets.dart';
import 'package:pp_transfer/pp_transfer.dart';

///
/// Created by a0010 on 2025/3/3 10:46
///
class WifiModel extends InheritedNotifier<WifiInfo> {
  const WifiModel({super.key, super.notifier, required super.child});

  // 定义一个便捷方法，方便子树中的widget获取共享数据
  static WifiInfo of(BuildContext context) => //
      context.dependOnInheritedWidgetOfExactType<WifiModel>()!.notifier!;

  static WifiInfo read(BuildContext context) => //
      context.getInheritedWidgetOfExactType<WifiModel>()!.notifier!;
}

class WifiInfo extends ChangeNotifier {
  List<SocketAddress> get devices => _peers;
  List<SocketAddress> _peers = [];

  void updateDevices(List<SocketAddress> list) {
    _peers = list;
    notifyListeners();
  }
}
