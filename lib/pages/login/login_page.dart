import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/base/http/api_client.dart';
import 'package:flutter_ui/base/res/strings.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/entities/user_entity.dart';
import 'package:flutter_ui/pages/main/main_page.dart';
import 'package:flutter_ui/utils/sp_util.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String _username = '';
  String _password = '';
  bool _isDisableLoginButton = true;
  bool _isShowPwd = false;

  @override
  void initState() {
    super.initState();

    _initInputText();
  }

  // 初始化输入框的内容，如果本地储存账号和密码，获取并填充到输入框
  void _initInputText() {
    usernameController.text = _username = SpUtil.getUsername();
    usernameController.addListener(() {
      setState(() => _username = usernameController.text);
      _resetLoginButtonState();
    });
    passwordController.addListener(() {
      setState(() => _password = passwordController.text);
      _resetLoginButtonState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of.login, style: TextStyle(color: Colors.white))),
      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.only(top: 100), child: _body()),
      ),
    );
  }

  // 主体页面结构
  Widget _body() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
            icon: Icon(Icons.person),
            labelText: S.of.username,
            suffixIcon: IconButton(
              splashColor: Colors.transparent,
              icon: Icon(Icons.close),
              onPressed: () => usernameController.clear(),
            ),
          ),
          maxLines: 1,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: 32),
        TextField(
          controller: passwordController,
          decoration: InputDecoration(
            icon: Icon(Icons.admin_panel_settings),
            labelText: S.of.password,
            suffixIcon: IconButton(
              splashColor: Colors.transparent,
              icon: Icon(_isShowPwd ? Icons.visibility : Icons.visibility_off, size: 20),
              iconSize: 16,
              // 点击改变显示或隐藏密码
              onPressed: () => setState(() => _isShowPwd = !_isShowPwd),
            ),
          ),
          maxLines: 1,
          keyboardType: TextInputType.text,
          obscureText: !_isShowPwd,
        ),
        SizedBox(height: 32),
        Row(children: [
          Expanded(
            flex: 1,
            child: TapLayout(
              height: 36.0,
              borderRadius: BorderRadius.all(Radius.circular(2)),
              background: _isDisableLoginButton ? Colors.blue.shade200 : Colors.blue,
              onTap: _isDisableLoginButton ? null : _loginPressed,
              child: Text(S.of.login, style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ]),
    );
  }

  // 如果输入的账号密码为空则禁用登录按钮
  void _resetLoginButtonState() {
    setState(() => _isDisableLoginButton = _username.isEmpty || _password.isEmpty);
  }

  // 登录按钮点击事件
  void _loginPressed() {
    FocusScope.of(context).unfocus();
    ApiClient.getInstance.request(apiServices.login(_username, _password), success: (data) {
      UserEntity user = UserEntity.fromJson(data);
      SpUtil.setIsLogin(true);
      SpUtil.setUser(jsonEncode(user));
      SpUtil.setUsername(user.username);
      SpUtil.setUserId(user.id.toString());
      SpUtil.setToken(user.token);

      _pushMainPage();
    });
  }

  void _pushMainPage() {
    RouteManager.push(MainPage(), clearStack: true);
  }
}
