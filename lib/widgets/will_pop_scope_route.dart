import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/channels/native_channels.dart';

/// 控制返回键的动作
class WillPopScopeRoute extends StatefulWidget {
  final Widget child;
  final bool moveTaskToBack;

  WillPopScopeRoute(
    this.child, {
    this.moveTaskToBack = false,
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
        onWillPop: _exit,
        child: widget.child,
      ),
    );
  }

  Future<bool> _exit() async {
    if (widget.moveTaskToBack) {
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
    } else {
      NativeChannels.backToDesktop();
      return false;
    }
  }
}
