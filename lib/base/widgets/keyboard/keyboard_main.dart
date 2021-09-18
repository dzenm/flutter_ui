import 'package:flutter/material.dart';

import 'CustomJPasswordFieldWidget.dart';
import 'keyboard_widget.dart';
import 'pay_password.dart';

/// 支付密码  +  自定义键盘
class main_keyboard extends StatefulWidget {
  static final String sName = "enter";

  @override
  State<StatefulWidget> createState() => _LicenseKeyboardState();
}

class _LicenseKeyboardState extends State<main_keyboard> {
  String pwdData = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  VoidCallback? _showBottomSheetCallback;

  @override
  void initState() {
    super.initState();
    _showBottomSheetCallback = _showBottomSheet;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext c) {
    return Container(
      height: 300.0,
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Text(
              '请在此输入新支付密码',
              style: TextStyle(fontSize: 18.0, color: Color(0xff333333)),
            ),
          ),
          ///密码框
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: _buildPwd(pwdData),
          ),

//          Padding(
//            padding: const EdgeInsets.only(top: 20.0),
//            child: Text(
//              '不是登录密码或连续数字',
//              style: TextStyle(fontSize: 12.0, color: Color(0xff999999)),
//            ),
//          ),

//          Padding(
//            padding: const EdgeInsets.only(top: 30.0), //0xffff0303
//            child: Text(
//              '密码输入错误，还可输入2次，超出将锁定账户。',
//              style: TextStyle(fontSize: 12.0, color: Color(0xffffffff)),
//            ),
//          ),
        ],
      ),
    );
  }

  /// 密码键盘 确认按钮 事件
  void onAffirmButton() {}

  void _onKeyDown(KeyEvent data) {
    if (data.isDelete()) {
      if (pwdData.length > 0) {
        pwdData = pwdData.substring(0, pwdData.length - 1);
        setState(() {});
      }
    } else if (data.isCommit()) {
      if (pwdData.length != 6) {
//        Fluttertoast.showToast(msg: "密码不足6位，请重试", gravity: ToastGravity.CENTER);
        return;
      }
      onAffirmButton();
    } else {
      if (pwdData.length < 6) {
        pwdData += data.key;
      }
      setState(() {});
    }
  }

  /// 底部弹出 自定义键盘  下滑消失
  void _showBottomSheet() {
    setState(() {
      // disable the button
      _showBottomSheetCallback = null;
    });
    _scaffoldKey.currentState
        ?.showBottomSheet<void>((BuildContext context) {
          return MyKeyboard(_onKeyDown);
        })
        .closed
        .whenComplete(() {
          if (mounted) {
            setState(() {
              // re-enable the button
              _showBottomSheetCallback = _showBottomSheet;
            });
          }
        });
  }

  Widget _buildPwd(var pwd) {
    return GestureDetector(
      child: Container(
        width: 250.0,
        height: 40.0,
//      color: Colors.white,
        child: CustomJPasswordField(pwd),
      ),
      onTap: () {
        _showBottomSheetCallback!();
      },
    );
  }
}
