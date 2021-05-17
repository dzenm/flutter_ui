import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Android返回按钮动作
class AndroidBackAction {
  //初始化通信管道-设置退出到手机桌面
  static const String BACK_CHANNEL = "android/back/desktop";

  // 设置回退到手机桌面
  static Future<bool> moveTaskToBack() async {
    final platform = MethodChannel(BACK_CHANNEL);
    // 通知安卓返回,到手机桌面
    try {
      final bool out = await platform.invokeMethod('moveTaskToBack');
      return Future.value(out);
    } on PlatformException catch (e) {}
    return Future.value(false);
  }
}

class WillPopScopeRoute extends StatefulWidget {
  final Widget child;
  final bool moveTaskToBack;

  WillPopScopeRoute(
    this.child, {
    this.moveTaskToBack = true,
  });

  @override
  _WillPopScopeRoute createState() => _WillPopScopeRoute();
}

class _WillPopScopeRoute extends State<WillPopScopeRoute> {
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
        return true;
      }
    } else {
      AndroidBackAction.moveTaskToBack();
      return false;
    }
  }
}
