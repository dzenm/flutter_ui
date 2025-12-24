import 'package:flutter/material.dart';

import '../../config/notification.dart' as ln;

///
/// Created by a0010 on 2025/7/17 13:21
///
/// 共享模块的监听
mixin class SharedObserver implements ln.Observer {
  @mustCallSuper
  void addObserver() {}

  @mustCallSuper
  void removeObserver() {}

  @mustCallSuper
  @override
  Future<void> onReceiveNotification(ln.Notification notification) async {}
}

/// 页面的监听
mixin class StateObserver implements ln.Observer {
  void addObserver(String name) {
    var nc = ln.NotificationCenter();
    nc.addObserver(this, name);
  }

  void removeObserver(String name) {
    var nc = ln.NotificationCenter();
    nc.removeObserver(this, name);
  }

  @override
  Future<void> onReceiveNotification(ln.Notification notification) async {}
}

/// 共享数据的Model监听
mixin class ModelObserver implements SharedObserver {
  @mustCallSuper
  @override
  void addObserver() {}

  @mustCallSuper
  @override
  void removeObserver() {}

  @mustCallSuper
  @override
  Future<void> onReceiveNotification(ln.Notification notification) async {}

  @mustCallSuper
  void clear() {}

  void notify() {}
}

/// 刷新处理
mixin class SharedNotifyMixin {
  Future<void> post(String name, dynamic sender, [Map? info]) async {
    var nc = ln.NotificationCenter();
    await nc.postNotification(name, sender, info);
  }

  /// 获取数据的发送位置
  static dynamic getSender(ln.Notification notification) {
    return notification.sender is String ? '${notification.sender}' : notification.sender.runtimeType;
  }
}
