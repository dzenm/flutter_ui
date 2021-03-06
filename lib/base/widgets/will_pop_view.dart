import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/base/channels/native_channels.dart';

/// 点击返回时, 存在未保存的内容时弹出的提示框
Widget buildPromptBackDialog(BuildContext context) {
  return AlertDialog(
    title: Text('保存提示'),
    content: Text('是否将当前页面保存?'),
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

/// 返回时提示退出
/// 设置提示框，默认实现[buildPromptBackDialog]
Future<bool> promptBack(BuildContext context, {bool isChanged = false, bool isShowDialog = true, WidgetBuilder? builder}) async {
  if (isChanged && isShowDialog) {
    if (builder != null) {
      showDialog<bool>(
        context: context,
        builder: builder,
      ).then((value) {
        // 为true点击确定，false点击取消
        if (value ?? true) {
          Navigator.pop(context);
        }
      });
    }
  }
  return !isChanged; // 根据isChanged的值决定调用系统返回键的处理
}

/// 监听返回键的动作
class WillPopView extends StatefulWidget {
  final Widget child; //如果对返回键进行监听，必须放在最顶层
  final BackBehavior behavior; //返回键的行为
  final WillPopCallback? onWillPop;

  WillPopView({
    Key? key,
    required this.child,
    this.behavior = BackBehavior.custom,
    this.onWillPop,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WillPopViewState();
}

class _WillPopViewState extends State<WillPopView> {
  DateTime? _lastTap; //上次点击时间

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: WillPopScope(onWillPop: _onWillPop, child: widget.child),
    );
  }

  // 返回键事件，返回true，执行Navigator.pop(context)，返回false，则不执行
  Future<bool> _onWillPop() async {
    switch (widget.behavior) {
      case BackBehavior.custom:
        return widget.onWillPop == null ? Future.value(true) : widget.onWillPop!();
      case BackBehavior.background:
        await NativeChannels.onBackToDesktop();
        return false;
      case BackBehavior.doubleTap:
        DateTime now = DateTime.now();
        if (_lastTap == null || now.difference(_lastTap!) > Duration(seconds: 2)) {
          // 两次点击间隔超过2秒则重新计时
          _lastTap = now;
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
    }
  }
}

/// 返回行为
enum BackBehavior {
  custom, // 自定义返回键执行的方式
  background, // 点击返回键使页面处于后台运行,不销毁页面
  doubleTap, // 双击返回键退出页面
}
