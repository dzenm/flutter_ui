import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ui/pages/main/main_route.dart';
import 'package:flutter_ui/router/navigator_utils.dart';
import 'package:flutter_ui/widgets/common_view.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController usernameController;
  late TextEditingController passwordController;

  String username = '';
  String password = '';

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController()
      ..addListener(() {
        setState(() => username = usernameController.text);
      });
    passwordController = TextEditingController()
      ..addListener(() {
        setState(() => password = passwordController.text);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context: context, title: '登录'),
      body: Center(
        child: _body(),
      ),
    );
  }

  Widget _body() {
    bool isNotEmptyText = username.isNotEmpty && password.isNotEmpty;
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: usernameController,
          decoration: InputDecoration(
            icon: Icon(Icons.person),
            labelText: '用户名/手机号/邮箱',
            suffixIcon: IconButton(
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
            labelText: '密码',
            suffixIcon: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => passwordController.clear(),
            ),
          ),
          maxLines: 1,
          keyboardType: TextInputType.text,
          obscureText: true,
        ),
        SizedBox(height: 32),
        Row(children: [
          Expanded(
            flex: 1,
            child: MaterialButton(
              color: Colors.blue,
              onPressed: _loginPressed,
              child: Text('登录', style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ]),
    );
  }

  void _loginPressed() {
    NavigatorUtils.push(context, MainRoute.main);
  }
}
