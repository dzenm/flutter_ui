import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/channels/native_channels.dart';

/// 监听返回键的动作
class WillPopScopeRoute extends StatefulWidget {
  final Widget child; //如果对返回键进行监听，必须放在最顶层
  final BackBehavior behavior; //返回键的行为
  final WillPopCallback? onWillPop;
  final bool isChanged; //仅对[BackBehavior.prompt]生效，即页面数据发生变化时，会提示对数据的操作
  final WidgetBuilder? builder; //仅对[BackBehavior.prompt]生效，设置提示框

  WillPopScopeRoute(
    this.child, {
    Key? key,
    this.behavior = BackBehavior.background,
    this.onWillPop,
    this.isChanged = false,
    this.builder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WillPopScopeRouteState();
}

class _WillPopScopeRouteState extends State<WillPopScopeRoute> {
  DateTime? _lastPressedAt; //上次点击时间

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: WillPopScope(onWillPop: _onWillPop, child: widget.child),
    );
  }

  // 返回键事件，返回true，执行Navigator.pop(context)，返回false，则不执行
  Future<bool> _onWillPop() async {
    switch (widget.behavior) {
      case BackBehavior.background:
        NativeChannels.onBackToDesktop();
        return false;
      case BackBehavior.doubleTap:
        if (_lastPressedAt == null || DateTime.now().difference(_lastPressedAt!) > Duration(seconds: 2)) {
          // 两次点击间隔超过2秒则重新计时
          _lastPressedAt = DateTime.now();
          BotToast.showText(
            text: '再次点击退出程序',
            onlyOne: true,
            textStyle: TextStyle(fontSize: 14, color: Colors.white),
          );
          return false;
        } else {
          // 退出app
          exit(0);
        }
      case BackBehavior.prompt:
        return _promptBack(widget.isChanged);
      case BackBehavior.custom:
        return widget.onWillPop == null ? Future.value(true) : widget.onWillPop!();
    }
  }

  // 返回时提示退出
  Future<bool> _promptBack(bool isChanged) async {
    if (isChanged) {
      bool isBackResult = false; // 默认不返回
      showDialog<bool>(
        context: context,
        builder: widget.builder ?? _buildBackDialogPrompt,
      ).then((value) {
        isBackResult = value ?? true;
        if (isBackResult) {
          Navigator.pop(context);
        }
      });
      return isBackResult;
    } else {
      return true;
    }
  }

  // 点击返回时, 存在未保存的内容时弹出的提示框
  Widget _buildBackDialogPrompt(BuildContext context) {
    return AlertDialog(
      title: Text('保存提示'),
      content: Text('是否将当前页面保存为草稿?'),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 8.0),
      actions: [
        TextButton(
          child: Text('取消'),
          onPressed: () => Navigator.pop(context, false),
        ),
        TextButton(
          child: Text('确定'),
          onPressed: () => Navigator.pop(context, true),
        ),
      ],
    );
  }
}

/// 返回行为
enum BackBehavior {
  /// 点击返回键使页面处于后台运行,不销毁页面
  background,

  /// 双击返回键退出页面
  doubleTap,

  /// 退出前的提示
  prompt,

  /// 自定义返回键执行的方式
  custom,
}
