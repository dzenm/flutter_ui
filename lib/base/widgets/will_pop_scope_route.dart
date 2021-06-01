import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/channels/native_channels.dart';

/// 控制返回键的动作
class WillPopScopeRoute extends StatefulWidget {
  final Widget child; // 如果对返回键进行监控时，必须放在最顶层，其他页面作为子widget
  final BackEvent event; // 返回键的事件类型
  final bool isChanged; // 仅对[BackEvent.unsavedPrompt]生效，即页面数据发生变化时，会提示对数据的操作
  final WidgetBuilder? builder; // 仅对[BackEvent.unsavedPrompt]生效，即页面数据发生变化时，弹出框的提示widget

  WillPopScopeRoute(
    this.child, {
    this.event = BackEvent.moveTaskToBack,
    this.isChanged = false,
    this.builder,
  });

  @override
  State<StatefulWidget> createState() => _WillPopScopeRouteState();
}

class _WillPopScopeRouteState extends State<WillPopScopeRoute> {
  DateTime? _lastPressedAt; //上次点击时间

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: widget.child,
      ),
    );
  }

  // 返回键事件，返回true，执行Navigator.pop(context)，返回false，则不执行
  Future<bool> _onBackPressed() async {
    switch (widget.event) {
      case BackEvent.moveTaskToBack:
        NativeChannels.backToDesktop();
        return false;
      case BackEvent.doubleClickToExit:
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
      case BackEvent.unsavedPrompt:
        return _unsavedPrompt(widget.isChanged);
    }
  }

  // 未保存的提示
  Future<bool> _unsavedPrompt(bool isChanged) async {
    if (isChanged) {
      bool isBackResult = true;
      showDialog<bool>(
        context: context,
        builder: widget.builder ?? _backDialogPrompt,
      ).then((value) {
        isBackResult = value ?? true;
        if (value == null) return;
        if (value) {
          Navigator.pop(context);
        }
      });
      return isBackResult;
    } else {
      return true;
    }
  }

  // 点击返回时, 存在未保存的内容时弹出的提示框
  Widget _backDialogPrompt(BuildContext context) {
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

/// 返回键事件
enum BackEvent {
  moveTaskToBack, // 返回不销毁页面
  doubleClickToExit, // 双击退出页面
  unsavedPrompt, // 未保存提示
}
