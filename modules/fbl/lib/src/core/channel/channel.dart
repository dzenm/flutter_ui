import 'dart:async';

import 'package:flutter/services.dart';

///
/// Created by a0010 on 2025/12/18 11:26
///
/// Flutter端注册原生通信
abstract class FlutterChannel {
  String get channelName; // 信道名称

  /// 注册监听
  void addObserver() {}

  /// 取消注册监听
  void removeObserver() {}
}

/// Flutter端注册Method原生通信
abstract class FlutterMethodChannel implements FlutterChannel {}

/// Flutter端注册Event原生通信
abstract class FlutterEventChannel implements FlutterChannel {
  /// 接收来自原生的数据流
  StreamSubscription? _stream;

  @override
  void addObserver() {
    var channel = EventChannel(channelName);
    // 监听Event事件
    _stream = channel.receiveBroadcastStream().listen(
      _onData,
      onError: _onError,
    );
  }

  void _onData(dynamic event) {
    Map<Object?, Object?> map = event;
    Map<String, dynamic> json = map.map(
          (key, value) => MapEntry(key.toString(), value),
    );
    onData(json);
  }

  /// 接收回调数据
  void onData(Map<String, dynamic> json);

  void _onError(dynamic error, StackTrace stackTrace) {
    onError(error, stackTrace);
  }

  /// 接收回调的错误
  void onError(dynamic error, StackTrace stackTrace) {}

  @override
  void removeObserver() {
    StreamSubscription? stream = _stream;
    _stream = null;
    if (stream != null) {
      stream.cancel();
    }
  }
}

/// Flutter端通道创建
class FlutterChannelFactory {
  final Set<FlutterChannel> _channels = {};

  FlutterChannelFactory({
    required List<FlutterChannel> channels,
  }) {
    Set<FlutterChannel> allChannels = _channels;
    for (var item in channels) {
      if (allChannels.add(item)) {
        item.addObserver();
      }
    }
  }
}

