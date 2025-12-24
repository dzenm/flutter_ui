import 'dart:async';

import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
/// Created by a0010 on 2025/12/10 14:34
///
/// 软键盘的监听
abstract class SoftKeyboardObserver {
  /// 可见回调
  /// [isVisible] 软键盘是否可见
  /// [height] isVisible=true时为软键盘可见时的最大高度，isVisible=false时软键盘高度为0
  void onVisible(SoftKeyboardState softKeyboardState);
}

/// 软键盘状态信息
class SoftKeyboardState {
  bool get isSoftKeyboardVisible => _isSoftKeyboardVisible;
  bool _isSoftKeyboardVisible = false; // 是否显示软键盘
  double get softKeyboardHeight => _softKeyboardHeight;
  double _softKeyboardHeight = 0.0; // 当前的软键盘高度
  bool get isNavigationBarVisible => _isNavigationBarVisible;
  bool _isNavigationBarVisible = false; // 是否显示导航栏
  double get navigationBarHeight => _navigationBarHeight;
  double _navigationBarHeight = 0.0; // 当前的导航栏高度

  SoftKeyboardState.fromJson(Map<String, dynamic> json) {
    _isSoftKeyboardVisible = json["isSoftKeyboardVisible"] ?? false;
    _softKeyboardHeight = json["softKeyboardHeight"] ?? 0.0;
    _isNavigationBarVisible = json["isNavigationBarVisible"] ?? false;
    _navigationBarHeight = json["navigationBarHeight"] ?? 0.0;
  }

  Map<String, dynamic> toJson() => {
    "isSoftKeyboardVisible": _isSoftKeyboardVisible,
    "softKeyboardHeight": _softKeyboardHeight,
    "isNavigationBarVisible": _isNavigationBarVisible,
    "navigationBarHeight": _navigationBarHeight,
  };
}

/// 监听原生软键盘弹出与隐藏
class SoftKeyboardStream extends FlutterEventChannel with Logging {
  static const String _kSoftKeyboardChannel = "flutter_ui/stream/keyboard";

  factory SoftKeyboardStream() => _instance; //
  static final SoftKeyboardStream _instance = SoftKeyboardStream._internal(); //
  SoftKeyboardStream._internal(); //

  /// 键盘监听的接口
  final List<SoftKeyboardObserver> _observers = [];

  /// 注册监听
  void addListener(SoftKeyboardObserver observer) {
    _observers.add(observer);
  }

  /// 取消注册监听
  void removeListener(SoftKeyboardObserver observer) {
    _observers.remove(observer);
  }

  @override
  String get channelName => _kSoftKeyboardChannel;

  @override
  void onData(Map<String, dynamic> json) {
    logDebug("接收到原生对键盘的检测回调：json=$json");
    SoftKeyboardState softKeyboardState = SoftKeyboardState.fromJson(json);
    List<SoftKeyboardObserver> observers = _observers;
    for (var item in observers) {
      item.onVisible(softKeyboardState);
    }
  }

  @override
  void onError(error, StackTrace stackTrace) {
    logError("Event error：$error");
  }
}

/// 软键盘可见性处理
mixin SoftKeyboardVisibleMixin<T extends StatefulWidget> on State<T> //
    implements
        SoftKeyboardObserver {
  @override
  void initState() {
    super.initState();
    SoftKeyboardStream().addListener(this);
  }

  @override
  void dispose() {
    super.dispose();
    SoftKeyboardStream().removeListener(this);
  }

  @override
  void onVisible(SoftKeyboardState softKeyboardState);
}

/// 创建自定义的键盘监听
class GlobalSoftKeyboard implements SoftKeyboardObserver {
  final void Function(SoftKeyboardState softKeyboardState) onChanged;

  const GlobalSoftKeyboard(this.onChanged);

  @override
  void onVisible(SoftKeyboardState softKeyboardState) {
    onChanged.call(softKeyboardState);
  }
}

/// 键盘操作
abstract class SoftKeyboardManager {
  /// 弹出键盘
  static Future<void> show() async {
    // 显示键盘
    await SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  /// 隐藏键盘
  static Future<void> hide() async {
    // 隐藏键盘
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
  }
}
