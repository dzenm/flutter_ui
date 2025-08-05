import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

///
/// Created by a0010 on 2024/12/30 15:58
/// 包裹某一类布局的通用组件
///

/// 区分平台布局
class PlatformWrapper extends StatelessWidget {
  final Widget? androidView;
  final Widget? iOSView;
  final Widget? windowsView;
  final Widget? macOSView;
  final Widget? linuxView;
  final Widget? webView;

  const PlatformWrapper({
    super.key,
    this.androidView,
    this.iOSView,
    this.windowsView,
    this.macOSView,
    this.linuxView,
    this.webView,
  });

  const PlatformWrapper.builder({
    super.key,
    Widget? mobileView,
    Widget? desktopView,
    Widget? webView,
  })  : androidView = mobileView,
        iOSView = mobileView,
        windowsView = desktopView,
        macOSView = desktopView,
        linuxView = desktopView,
        webView = webView ?? desktopView;

  @override
  Widget build(BuildContext context) {
    Widget? child;
    if (kIsWeb) {
      child = webView;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      child = androidView;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      child = iOSView;
    } else if (defaultTargetPlatform == TargetPlatform.windows) {
      child = windowsView;
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      child = macOSView;
    } else if (defaultTargetPlatform == TargetPlatform.linux) {
      child = linuxView;
    }
    return child ?? const Placeholder();
  }
}

///
/// 监听返回键的动作
class PopWrapper extends StatelessWidget {
  final Widget child; //如果对返回键进行监听，必须放在最顶层
  final BackBehavior behavior; //返回键的行为
  final PopInvokedCallback? onPopInvoked;

  const PopWrapper({
    super.key,
    required this.child,
    this.behavior = BackBehavior.custom,
    this.onPopInvoked,
  });

  const PopWrapper.exit({
    Key? key,
    required Widget child,
  }) : this(
          key: key,
          child: child,
          behavior: BackBehavior.doubleTap,
        );

  const PopWrapper.background({
    Key? key,
    required Widget child,
  }) : this(
          key: key,
          child: child,
          behavior: BackBehavior.background,
        );

  const PopWrapper.custom({
    Key? key,
    required Widget child,
    PopInvokedCallback? onPopInvoked,
  }) : this(
          key: key,
          child: child,
          behavior: BackBehavior.custom,
          onPopInvoked: onPopInvoked,
        );

  /// 点击返回时, 存在未保存的内容时弹出的提示框
  static Widget _buildPromptBackDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('保存提示'),
      content: const Text('是否将当前页面保存?'),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
      actions: [
        TextButton(
          child: const Text('取消'),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          child: const Text('确定'),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }

  /// 返回时提示退出
  /// 设置提示框，默认实现[_buildPromptBackDialog]
  /// PopWrapper(
  //    onWillPop: () => PopWrapper.promptBack(context, isChanged: text != newText),
  //    child: Scaffold(),
  //  )
  static Future<bool> showPrompt(
    BuildContext context, {
    WidgetBuilder? builder,
  }) async {
    var result = await showDialog<bool>(
          context: context,
          builder: builder ?? _buildPromptBackDialog,
        ) ??
        true;
    return result;
  }

  static DateTime _lastTap = DateTime.now(); //上次点击时间

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: _onPopInvoked,
      canPop: false,
      child: child,
    );
  }

  // 返回键事件，返回true，执行Navigator.pop(context)，返回false，则不执行
  void _onPopInvoked(bool didPop) async {
    switch (behavior) {
      case BackBehavior.custom:
        if (didPop) {
          return;
        }
        if (onPopInvoked != null) {
          onPopInvoked!(didPop);
        }
        break;
      case BackBehavior.background:
        break;
      case BackBehavior.doubleTap:
        DateTime now = DateTime.now();
        if (now.difference(_lastTap) > const Duration(seconds: 2)) {
          // 两次点击间隔超过2秒则重新计时
          _lastTap = now;
          BotToast.showText(
            text: '再次点击退出程序',
            onlyOne: true,
            textStyle: const TextStyle(fontSize: 14, color: Colors.white),
          );
        } else {
          // 退出app
          exit(0);
        }
        break;
    }
  }
}

/// 返回行为
enum BackBehavior {
  custom, // 自定义返回键执行的方式
  background, // 点击返回键使页面处于后台运行,不销毁页面
  doubleTap, // 双击返回键退出页面
}

///
/// 缓存PageView的子页面，使其不被销毁
/// KeepAliveWrapper(
///   child: TabBarView(children: _tabItems),
/// )
class KeepAliveWrapper extends StatefulWidget {
  final bool keepAlive;
  final Widget child;

  const KeepAliveWrapper({
    super.key,
    this.keepAlive = true,
    required this.child,
  });

  @override
  State<StatefulWidget> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  void didUpdateWidget(KeepAliveWrapper oldWidget) {
    // 状态发生变化时调用
    if (oldWidget.keepAlive != widget.keepAlive) {
      // 更新KeepAlive状态
      updateKeepAlive();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  bool get wantKeepAlive => widget.keepAlive;
}

class ScreenWrapper extends StatelessWidget {
  final Widget child;
  final Color color;

  const ScreenWrapper({
    super.key,
    required this.child,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: child,
    );
  }
}

class ScreenBodyWrapper extends StatelessWidget {
  final Widget child;
  final Color color;
  final EdgeInsets? padding;

  const ScreenBodyWrapper({
    super.key,
    required this.child,
    this.color = Colors.white,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      padding: padding ?? const EdgeInsets.all(16),
      child: child,
    );
  }
}

/// 自动固定屏幕垂直，[enterVertical] 在进入屏幕前是否需要固定屏幕垂直, [exitVertical] 在
/// 退出屏幕后是否需要固定屏幕垂直，二者默认都为true，如需改变，实现并重写即可
mixin FixedScreenVerticalMixin<T extends StatefulWidget> on State<T> {
  bool get enterVertical => true; // 是否进入垂直
  bool get exitVertical => true; // 是否退出垂直

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(_getOrientation(enterVertical));
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(_getOrientation(exitVertical));
    super.dispose();
  }

  List<DeviceOrientation> _getOrientation(bool vertical) {
    if (vertical) {
      return [DeviceOrientation.portraitUp];
    }
    return [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ];
  }
}

/// 自动切换全屏和垂直屏幕
mixin AutomaticFullScreenMixin<T extends StatefulWidget> on State<T> {
  void toggleScreen() {
    Orientation current = MediaQuery.of(context).orientation;
    if (current == Orientation.landscape) {
      // 如果是全屏就切换竖屏
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      // 如果是竖屏就切换全屏
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }
}
