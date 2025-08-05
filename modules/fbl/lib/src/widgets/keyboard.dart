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
///   @override
///   void initState() {
///     super.initState();
///     WidgetsBinding.instance.addObserver(this);
///   }
///
///   @override
///   void dispose() {
///     WidgetsBinding.instance.removeObserver(this);
///
///     super.dispose();
///   }
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
        ln.Observer {
  FocusNode get focusNode => _focusNode;
  late FocusNode _focusNode; // 输入框的焦点实例

  SoftKeyboardValue get value => _value;
  final SoftKeyboardValue _value = SoftKeyboardValue();

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _focusNode.addListener(_onFocus); // 监听输入框焦点变化

    var nc = ln.NotificationCenter();
    nc.addObserver(this, KeyboardNames.kGlobalScreenTap);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocus); // 取消监听输入框焦点变化
    _focusNode.dispose();

    var nc = ln.NotificationCenter();
    nc.removeObserver(this, KeyboardNames.kGlobalScreenTap);
    super.dispose();
  }

  void didScreenKeyboardChanged({bool isPostFrame = false}) {
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
    Log.d('键盘变化：height=$height', tag: 'KeyboardObserverMixin');

    double lastHeight = _value._lastHeight;
    double maxHeight = _value._maxHeight;
    SoftKeyboardPosition position = _value._position;

    if (_value._isRunning) {
      // 正在变化中

      if ((position == SoftKeyboardPosition.inBottom && height == 0.0) || //
          (position == SoftKeyboardPosition.inTop && height == maxHeight)) {
        // 如果在最底部/最顶部重复执行，将不处理这次的回调
        return;
      }
      if (lastHeight < height) {
        // 键盘在上升（持续弹出）
        _value.setLastHeight(height);
        _value.setSoftKeyboardPosition(SoftKeyboardPosition.rising);
        onKeyboardChanging(SoftKeyboardPosition.rising, height);
      } else if (lastHeight > height) {
        // 键盘在下降（持续关闭）
        _value.setLastHeight(height);
        _value.setSoftKeyboardPosition(SoftKeyboardPosition.declining);
        onKeyboardChanging(SoftKeyboardPosition.declining, height);
      } else if (position == SoftKeyboardPosition.declining && lastHeight == height && height == 0.0) {
        // 表示键盘从顶部开始向下关闭且此时高度为0.0，已经完全关闭
        _value.setSoftKeyboardPosition(SoftKeyboardPosition.inBottom);
        _value.setLastTime(DateTime.now());
        _value.setRunning(false);
        _updateKeyboardPaddingBottom();
        Log.d('键盘从顶部开始向下隐藏并已经完全关闭：currentHeight=$height', tag: 'KeyboardObserverMixin');
        onKeyboardChangedEnd(SoftKeyboardPosition.inBottom);
      } else if (position == SoftKeyboardPosition.rising && lastHeight == height && height > 0) {
        // 表示键盘从底部开始向上弹出且此时高度跟上一次一样，已经完全弹出
        _value.setSoftKeyboardPosition(SoftKeyboardPosition.inTop);
        _value.setLastTime(DateTime.now());
        _value.setRunning(false);
        Log.d('键盘从底部开始向上弹出并已经完全弹出：currentHeight=$height', tag: 'KeyboardObserverMixin');
        onKeyboardChangedEnd(SoftKeyboardPosition.inTop);
      }
      return;
    }

    if (height == 0.0) {
      DateTime? lastTopTime = _value._lastTime;
      if (lastTopTime != null && //
          lastTopTime.add(const Duration(milliseconds: 500)).isAfter(DateTime.now())) {
        // 从顶部隐藏后，如果未超过500毫秒，会从底部重新弹起
        return;
      }
      // 上一次为0.0，表示从底部开始
      _value.setLastHeight(height);
      _value.setSoftKeyboardPosition(SoftKeyboardPosition.inBottom);
      _value.setLastTime(DateTime.now());
      _value.setRunning(true);
      _updateKeyboardPaddingBottom();
      Log.d('键盘从底部开始向上弹出：currentHeight=$height', tag: 'KeyboardObserverMixin');
      onKeyboardChangedStart(SoftKeyboardPosition.inBottom);
    } else if (height == maxHeight) {
      // 否则表示从顶部开始
      _value.setLastHeight(height);
      _value.setSoftKeyboardPosition(SoftKeyboardPosition.inTop);
      _value.setLastTime(DateTime.now());
      _value.setRunning(true);
      Log.d('键盘从顶部开始向下隐藏：currentHeight=$height', tag: 'KeyboardObserverMixin');
      onKeyboardChangedStart(SoftKeyboardPosition.inTop);
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

  /// 弹出键盘
  void showKeyboard() {
    if (value.position == SoftKeyboardPosition.inBottom) {
      // 显示键盘
      SystemChannels.textInput.invokeMethod('TextInput.show');
    }
  }

  /// 隐藏键盘
  void hideKeyboard() {
    if (value.position == SoftKeyboardPosition.inTop) {
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
  double get height => _height;
  double _height = 0.0; // 记录当前的高度
  void setHeight(double height) {
    double oldHeight = _height;
    _height = height;
    if (oldHeight != height) return;
    // 高度变化时，在开始/结束的变化中会回调两次，其它的变化过程中只会回调一次，
    if (height == 0.0) {
      // 到达最底部
    } else if (height > 0.0) {
      // 到达最顶部
      _maxHeight = height;
    }
  }

  double get maxHeight => _maxHeight;
  double _maxHeight = 0.0; // 记录最大高度

  double get paddingBottom => _paddingBottom;
  double _paddingBottom = 0.0; // 键盘底部距离屏幕底部的内间距，
  void setPaddingBottom(double paddingBottom) => _paddingBottom = paddingBottom;

  SoftKeyboardPosition get position => _position;
  SoftKeyboardPosition _position = SoftKeyboardPosition.inBottom; // 当前键盘的位置
  void setSoftKeyboardPosition(SoftKeyboardPosition position) => _position = position;

  double _lastHeight = 0.0; // 记录上一次的高度
  void setLastHeight(double lastHeight) => _lastHeight = lastHeight;
  bool _isRunning = false; // 是否正在变化中
  void setRunning(bool isRunning) => _isRunning = isRunning;
  DateTime? _lastTime; // 记录结束变化的时间
  void setLastTime(DateTime lastTime) => _lastTime = lastTime;

  Map<String, dynamic> toJson() => {
        'height': _height,
        'maxHeight': _maxHeight,
        'paddingBottom': _paddingBottom,
        'position': _position,
        'isRunning': _isRunning,
        'lastHeight': _lastHeight,
        'lastTime': _lastTime,
      };
}

/// 软键盘活动的位置
enum SoftKeyboardPosition {
  inTop, // 最顶部，键盘完全显示
  rising, // 持续上升，键盘正在弹出中
  inBottom, // 最底部，键盘完全隐藏
  declining, // 持续下降，键盘正在关闭中
}
