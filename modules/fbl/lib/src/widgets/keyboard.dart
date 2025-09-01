import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/config.dart' as ln;
import '../config/config.dart';

///
/// Created by a0010 on 2025/6/24 16:03
class GlobalScreenGestureWrapper extends StatelessWidget {
  final Widget child;
  final bool removeFocus;

  const GlobalScreenGestureWrapper({super.key, required this.child, this.removeFocus = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (removeFocus) {
          FocusScope.of(context).unfocus();
        } else {
          var nc = ln.NotificationCenter();
          nc.postNotification(KeyboardNames.kGlobalScreenTap, this, {});
        }
      },
      child: child,
    );
  }
}

/// 键盘事件监听
abstract class KeyboardNames {
  static const String kGlobalScreenTap = 'GlobalScreenTap'; // 顶层全屏点击事件监听
}

///
/// abstract class _AbstractChatInputWidgetState extends State<ChatInputWidget> //
///     with KeyboardObserverMixin, WidgetsBindingObserver {
///
///   @override
///   void didChangeMetrics() {
///     super.didChangeMetrics();
///     didScreenKeyboardChanged();
///   }
/// }
///
///
/// 监听键盘的变化
mixin KeyboardObserverMixin<T extends StatefulWidget> on State<T> //
    implements
        WidgetsBindingObserver,
        ln.Observer {
  FocusNode get focusNode => _focusNode;
  late FocusNode _focusNode; // 输入框的焦点实例

  SoftKeyboardValue get value => _value;
  final SoftKeyboardValue _value = SoftKeyboardValue();

  /// 获取通用的最大高度
  double get maxHeight {
    double pixelRatio = MediaQuery.devicePixelRatioOf(context);
    double height = _value._maxHeight / pixelRatio;
    String s = height.toStringAsFixed(2);
    double maxHeight = double.parse(s);
    return maxHeight;
  }

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _focusNode.addListener(_onFocus); // 监听输入框焦点变化

    var nc = ln.NotificationCenter();
    nc.addObserver(this, KeyboardNames.kGlobalScreenTap);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocus); // 取消监听输入框焦点变化
    _focusNode.dispose();

    var nc = ln.NotificationCenter();
    nc.removeObserver(this, KeyboardNames.kGlobalScreenTap);

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void didScreenKeyboardChanged() {
    if (!mounted) return;
    if (!_focusNode.hasFocus) return;
    if (_focusNode.context == null) return;
    onScreenKeyboardChanged();
    _updateKeyboardHeight();
  }

  /// 屏幕中的键盘发生变化时调用
  void onScreenKeyboardChanged() {}

  /// 更新键盘的高度
  void _updateKeyboardHeight() {
    // MediaQuery.of(context) 获取的高度每一次不一定相同
    // View.of(context) 获取的高度需要除以屏幕的像素比
    double height = View.of(context).viewInsets.bottom;
    _value.setHeight(height);

    double oldHeight = _value._lastHeight;
    double maxHeight = _value._maxHeight;
    SoftKeyboardPosition position = _value._position;

    if (oldHeight == height && height == SoftKeyboardValue.minValue) {
      SoftKeyboardPosition newPosition = SoftKeyboardPosition.inBottom;
      // 处于最底部
      _value.setSoftKeyboardPosition(newPosition);
      _value._log('当前键盘处于底部：height=$height, position=$newPosition');
      if (position.isDeclining) {
        // 上一次高度等于当前高度，并且是下降的过程中，表示到达了底部
        onKeyboardChangedEnd(newPosition);
        _value._log('当前键盘下降到底部：$position -> $newPosition');
        _updateKeyboardPaddingBottom();
      }
    } else if (oldHeight == height && height == maxHeight) {
      SoftKeyboardPosition newPosition = SoftKeyboardPosition.inTop;
      // 处于最顶部
      _value.setSoftKeyboardPosition(newPosition);
      _value._log('当前键盘处于顶部：height=$height, position=$newPosition');
      if (position.isRising) {
        // 上一次高度等于当前高度，并且是上升的过程中，表示到达了顶部
        onKeyboardChangedEnd(newPosition);
        _value._log('当前键盘上升到顶部：$position -> $newPosition');
        _updateKeyboardPaddingBottom();
      }
    }
    if (oldHeight < height) {
      if (oldHeight == SoftKeyboardValue.minValue) {
        // 开始上升
        onKeyboardChangedStart(SoftKeyboardPosition.inBottom);
      }
      // 上一次高度小于当前高度，在上升的过程
      _value.setSoftKeyboardPosition(SoftKeyboardPosition.rising);
      _value._log('当前键盘处于变化：height=$height');
    }
    if (oldHeight > height) {
      if (oldHeight == maxHeight) {
        // 开始下降
        onKeyboardChangedStart(SoftKeyboardPosition.inTop);
      }
      // 上一次高度大于当前高度，在下降的过程
      _value.setSoftKeyboardPosition(SoftKeyboardPosition.declining);
      _value._log('当前键盘处于变化：height=$height');
    }
  }

  /// 更新键盘底部的高度
  void _updateKeyboardPaddingBottom() {
    double height = View.of(context).padding.bottom;
    _value.setPaddingBottom(height);
    Log.d('键盘底部内边距：paddingBottom=$height', tag: 'KeyboardObserverMixin');
  }

  void addListener(VoidCallback listener) {
    _focusNode.addListener(listener);
  }

  void removeListener(VoidCallback listener) {
    _focusNode.removeListener(listener);
  }

  void updatePosition(bool isShow) {
    if (isShow) {
      if (_value.position.isTop) return;
      _value.setSoftKeyboardPosition(SoftKeyboardPosition.inTop);
    } else {
      if (_value.position.isBottom) return;
      _value.setSoftKeyboardPosition(SoftKeyboardPosition.inBottom);
    }
  }

  /// 弹出键盘
  void showKeyboard() {
    _value._log("弹出键盘：isBottom=${_value.position.isBottom}, isMinHeight=${_value.isMinHeight}");
    if (_value.position.isBottom || _value.isMinHeight) {
      if (!_focusNode.hasFocus) {
        _focusNode.requestFocus();
      }
      // 显示键盘
      SystemChannels.textInput.invokeMethod('TextInput.show');
    } else if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
      // 显示键盘
      SystemChannels.textInput.invokeMethod('TextInput.show');
    }
  }

  /// 隐藏键盘
  void hideKeyboard() {
    if (_value.position.isTop || _value.isMaxHeight) {
      // 隐藏键盘
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
  }

  /// 焦点聚集时变化
  void onFocusChanged(bool hasFocus) {}

  // 焦点变化时触发的函数
  void _onFocus() {
    if (_focusNode.hasFocus) {
      onFocusChanged(true);
      // 聚焦时候的操作
      return;
    } else {
      onFocusChanged(false);
    }
  }

  /// 点击全局屏幕回调
  void onGlobalScreenTap() {}

  /// 键盘变化开始时调用
  void onKeyboardChangedStart(SoftKeyboardPosition position) {}

  /// 键盘变化过程中调用
  void onKeyboardChanging(SoftKeyboardPosition position, double height) {}

  /// 键盘变化完成时调用
  void onKeyboardChangedEnd(SoftKeyboardPosition position) {}

  @override
  Future<void> onReceiveNotification(ln.Notification notification) async {
    var name = notification.name;
    if (name == KeyboardNames.kGlobalScreenTap) {
      onGlobalScreenTap();
    }
  }
}

/// 软键盘变化过程的值
class SoftKeyboardValue {
  static const minValue = 0.0; // 最小值时的Value

  double get height => _height;
  double _height = minValue; // 记录当前的高度
  double _lastHeight = minValue; // 记录上一次的高度
  void setHeight(double height) {
    double oldHeight = _height;
    _height = height;
    _lastHeight = oldHeight;
    // 先检测最大高度
    _detectMaxHeight(oldHeight, height);
    // 再判断处于的状态
  }

  /// 检测是否到达最顶部
  void _detectMaxHeight(double oldHeight, double newHeight) {
    if (oldHeight == newHeight && newHeight > minValue) {
      _maxHeight = newHeight;
    }
  }

  bool get isMinHeight => _maxHeight == minValue; // 是否是最小的高度
  bool get isMaxHeight => _maxHeight > minValue && _height == _maxHeight; // 是否是最大的高度
  double _maxHeight = minValue; // 记录最大高度
  void setMaxHeight(double height) => _maxHeight = height;

  double get paddingBottom => _paddingBottom;
  double _paddingBottom = minValue; // 键盘底部距离屏幕底部的内间距，
  void setPaddingBottom(double paddingBottom) => _paddingBottom = paddingBottom;

  SoftKeyboardPosition get position => _position;
  SoftKeyboardPosition _position = SoftKeyboardPosition.inBottom; // 当前键盘的位置
  void setSoftKeyboardPosition(SoftKeyboardPosition position) => _position = position;

  void _log(String msg) => true ? Log.d(msg, tag: 'KeyboardObserverMixin') : null;

  Map<String, dynamic> toJson() => {
        'height': _height,
        'lastHeight': _lastHeight,
        'maxHeight': _maxHeight,
        'position': _position,
        'paddingBottom': _paddingBottom,
      };
}

/// 软键盘活动的位置
enum SoftKeyboardPosition {
  inTop, // 最顶部，键盘完全显示
  rising, // 持续上升，键盘正在弹出中
  inBottom, // 最底部，键盘完全隐藏
  declining; // 持续下降，键盘正在关闭中

  bool get isTop => this == inTop; // 是否在最顶部
  bool get isRising => this == rising; // 是否正在上升的过程中
  bool get isBottom => this == inBottom; // 是否在最底部
  bool get isDeclining => this == declining; // 是否正在下降的过程中
}
