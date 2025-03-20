import 'package:fbl/src/config/notification.dart' as ln;
import 'package:flutter/widgets.dart';
import 'package:pp_transfer/pp_transfer.dart';

///
/// Created by a0010 on 2025/3/3 10:46
///
class P2PWidget extends InheritedNotifier<PPModel> {
  const P2PWidget({super.key, super.notifier, required super.child});

  // 定义一个便捷方法，方便子树中的widget获取共享数据
  static PPModel of(BuildContext context) => //
      context.dependOnInheritedWidgetOfExactType<P2PWidget>()!.notifier!;

  static PPModel read(BuildContext context) => //
      context.getInheritedWidgetOfExactType<P2PWidget>()!.notifier!;
}

class PPModel extends ChangeNotifier implements ln.Observer {
  List<SocketAddress> get devices => _peers;
  final List<SocketAddress> _peers = [];

  PPModel() {
    var nc = ln.NotificationCenter();
    nc.addObserver(this, WifiDirectNames.kStatusChanged);
    nc.addObserver(this, WifiDirectNames.kSelfChanged);
    nc.addObserver(this, WifiDirectNames.kDevicesChanged);
  }

  @override
  void dispose() {
    var nc = ln.NotificationCenter();
    nc.removeObserver(this, WifiDirectNames.kStatusChanged);
    nc.removeObserver(this, WifiDirectNames.kSelfChanged);
    nc.removeObserver(this, WifiDirectNames.kDevicesChanged);
    super.dispose();
  }

  ServeStatus get status => _status;
  ServeStatus _status = ServeStatus.none;

  @override
  Future<void> onReceiveNotification(ln.Notification notification) async {
    var name = notification.name;
    if (name == WifiDirectNames.kStatusChanged) {
      var status = notification.userInfo?['status'];
      _status = status;
      notifyListeners();
    } else if (name == WifiDirectNames.kSelfChanged) {
      var self = notification.userInfo?['self'];
      _status = self;
      notifyListeners();
    } else if (name == WifiDirectNames.kDevicesChanged) {
      var peers = notification.userInfo?['peers'];
      _peers.clear();
      _peers.addAll(peers);
      notifyListeners();
    }

  }
}
