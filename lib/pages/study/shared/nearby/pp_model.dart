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
  List<SocketAddress> _peers = [];

  PPModel() {
    var nc = ln.NotificationCenter();
    nc.addObserver(this, WifiDirectNames.kStatusChanged);
    nc.addObserver(this, WifiDirectNames.kDevicesChanged);
    nc.addObserver(this, WifiDirectNames.kConnectionChanged);
    nc.addObserver(this, WifiDirectNames.kSelfChanged);
    nc.addObserver(this, WifiDirectNames.kReceiveTextData);
  }

  @override
  void dispose() {
    var nc = ln.NotificationCenter();
    nc.removeObserver(this, WifiDirectNames.kStatusChanged);
    nc.removeObserver(this, WifiDirectNames.kDevicesChanged);
    nc.removeObserver(this, WifiDirectNames.kConnectionChanged);
    nc.removeObserver(this, WifiDirectNames.kSelfChanged);
    nc.removeObserver(this, WifiDirectNames.kReceiveTextData);
    super.dispose();
  }

  ServeStatus get status => _status;
  ServeStatus _status = ServeStatus.none;

  WifiP2pDevice? get self => _self;
  WifiP2pDevice? _self;

  WifiP2pConnection? get connection => _connection;
  WifiP2pConnection? _connection;
  List<SocketAddress> get connectionDevices {
    List<SocketAddress> list = [];
    WifiP2pConnection? connection = _connection;
    if (connection == null) {
      return list;
    }
    WifiP2pGroup? group = connection.group;
    if (group == null) {
      return list;
    }

    WifiP2pDevice? self = _self;
    if (self != null) {
      list.add(mergeDevice(self, isGroupOwner: group.isGroupOwner));
    }
    if (!group.isGroupOwner) {
      list.add(mergeDevice(group.owner!, isGroupOwner: true));
    }
    for (var item in group.clients) {
      list.add(mergeDevice(item));
    }
    return list;
  }

  String getName(String? userUid) {
    WifiP2pDevice? device = getDevice(userUid);
    if (device == null) {
      return '';
    }
    return device.deviceName;
  }

  WifiP2pDevice? getDevice(String? userUid) {
    if (userUid == null) {
      return null;
    }
    WifiP2pConnection? connection = _connection;
    if (connection == null) {
      return null;
    }
    WifiP2pGroup? group = connection.group;
    if (group == null) {
      return null;
    }
    WifiP2pDevice? owner = group.owner;
    if (owner == null) {
      return null;
    }
    List<WifiP2pDevice> client = group.clients;
    var list = client.where((e) => e.deviceAddress == userUid).toList();
    if (list.isEmpty) {
      return null;
    }
    return list.first;
    ;
  }

  int get length => _iMsg.length;
  List<ChatMessage> get messages => _iMsg;
  final List<ChatMessage> _iMsg = [];
  ChatMessage? getMsg(int index) => index >= length ? null : _iMsg[index];
  void insertMsg(ChatMessage message) {
    _iMsg.add(message);
    notifyListeners();
  }

  void deleteMsg(int index) {
    _iMsg.removeAt(index);
    notifyListeners();
  }

  static SocketAddress mergeDevice(WifiP2pDevice device, {bool? isGroupOwner}) {
    return WifiDirectAddress(
      isGroupOwner: isGroupOwner ?? device.isGroupOwner,
      status: device.status,
      deviceName: device.deviceName,
      localAddress: '',
      remoteAddress: device.deviceAddress,
    );
  }

  @override
  Future<void> onReceiveNotification(ln.Notification notification) async {
    var name = notification.name;
    if (name == WifiDirectNames.kStatusChanged) {
      var status = notification.userInfo?['status'];
      _status = status;
      notifyListeners();
    } else if (name == WifiDirectNames.kDevicesChanged) {
      var peers = notification.userInfo?['peers'];

      List<WifiP2pDevice> list = peers as List<WifiP2pDevice>;
      List<SocketAddress> result = [];
      for (var item in list) {
        result.add(mergeDevice(item));
      }
      _peers = List.castFrom(result);
      notifyListeners();
    } else if (name == WifiDirectNames.kConnectionChanged) {
      var connection = notification.userInfo?['connection'];
      _connection = connection;
      notifyListeners();
    } else if (name == WifiDirectNames.kSelfChanged) {
      var self = notification.userInfo?['self'];
      _self = self;
      notifyListeners();
    } else if (name == WifiDirectNames.kReceiveTextData) {
      TextMessage message = notification.userInfo?['text'];
      _iMsg.add(message);
      notifyListeners();
    }
  }
}
