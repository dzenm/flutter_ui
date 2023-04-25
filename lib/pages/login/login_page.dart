import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../base/http/https_client.dart';
import '../../base/log/log.dart';
import '../../base/utils/route_manager.dart';
import '../../base/utils/sp_util.dart';
import '../../base/widgets/tap_layout.dart';
import '../../entities/user_entity.dart';
import '../../generated/l10n.dart';
import '../../models/user_model.dart';
import '../main/main_page.dart';
import 'register_page.dart';

///
/// 登录页面
///
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return _buildWebPage(context);
    }
    return _buildAppPage(context);
  }

  /// Web展示的页面
  Widget _buildWebPage(BuildContext context) {
    return Material(
      child: Center(
        child: Container(
          width: 400,
          padding: EdgeInsets.all(24),
          child: _LoginWidget(),
        ),
      ),
    );
  }

  /// App展示的页面
  Widget _buildAppPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).login, style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Stack(children: [
          SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(24),
              child: _LoginWidget(),
            ),
          )
        ]),
      ),
    );
  }
}

///
/// 登录组件主体部分的状态，不包含 [Scaffold]
///
class _LoginWidget extends StatefulWidget {
  const _LoginWidget();

  @override
  State<StatefulWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<_LoginWidget> {
  static const String _tag = 'LoginPage';

  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController rPasswordController = TextEditingController();

  String _username = '';
  String _password = '';
  String _rPassword = '';

  bool _isLoginAndRegisterPage = true; // 是否登陆注册双功能页面
  bool _switchCurrentLogin = true; // true为登陆，false为注册

  bool _isShowPwd = false; // 是否显示输入的密码
  bool _isShowRPwd = false; // 是否显示输入的重复密码

  bool _isDisableLoginButton = true; // 是否禁用点击按钮，根据输入的内容_isLogin为true禁用登陆按钮，为false禁用注册按钮

  @override
  void initState() {
    super.initState();
    Log.i('initState', tag: _tag);

    _initInputText();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.i('didChangeDependencies', tag: _tag);
  }

  @override
  void didUpdateWidget(covariant _LoginWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    Log.i('didUpdateWidget', tag: _tag);
  }

  @override
  void deactivate() {
    super.deactivate();
    Log.i('deactivate', tag: _tag);
  }

  @override
  void dispose() {
    super.dispose();
    Log.i('dispose', tag: _tag);

    usernameController.dispose();
    passwordController.dispose();
    rPasswordController.dispose();
  }

  // 初始化输入框的内容，如果本地储存账号和密码，获取并填充到输入框
  void _initInputText() {
    usernameController.text = _username = SpUtil.getUsername();
    usernameController.addListener(() {
      _username = usernameController.text;
      _resetLoginButtonState();
    });
    passwordController.addListener(() {
      _password = passwordController.text;
      _resetLoginButtonState();
    });
    rPasswordController.addListener(() {
      _rPassword = rPasswordController.text;
      _resetLoginButtonState();
    });
  }

  @override
  Widget build(BuildContext context) {
    Log.i('build', tag: _tag);

    MaterialColor buttonColor = Colors.blue;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      // 用户名输入框
      TextField(
        controller: usernameController,
        decoration: InputDecoration(
          icon: Icon(Icons.person),
          labelText: S.of(context).username,
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
      // 密码输入框
      TextField(
        controller: passwordController,
        decoration: InputDecoration(
          icon: Icon(Icons.admin_panel_settings),
          labelText: S.of(context).password,
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
      // 重复密码输入框
      if (!_switchCurrentLogin)
        TextField(
          controller: rPasswordController,
          decoration: InputDecoration(
            icon: Icon(Icons.admin_panel_settings),
            labelText: S.of(context).rPassword,
            suffixIcon: IconButton(
              splashColor: Colors.transparent,
              icon: Icon(_isShowRPwd ? Icons.visibility : Icons.visibility_off, size: 20),
              iconSize: 16,
              // 点击改变显示或隐藏密码
              onPressed: () => setState(() => _isShowRPwd = !_isShowRPwd),
            ),
          ),
          maxLines: 1,
          keyboardType: TextInputType.text,
          obscureText: !_isShowRPwd,
        ),
      if (!_switchCurrentLogin) SizedBox(height: 32),
      Row(children: [
        // 登陆按钮
        Expanded(
          flex: 1,
          child: TapLayout(
            height: 36.0,
            borderRadius: BorderRadius.all(Radius.circular(2)),
            background: _switchCurrentLogin && _isDisableLoginButton ? buttonColor.shade200 : buttonColor,
            onTap: _switchCurrentLogin && _isDisableLoginButton ? null : _login,
            child: Text(S.of(context).login, style: TextStyle(color: Colors.white)),
          ),
        ),
        SizedBox(height: 32, width: 64),
        // 注册按钮
        Expanded(
          flex: 1,
          child: TapLayout(
            height: 36.0,
            borderRadius: BorderRadius.all(Radius.circular(2)),
            background: !_switchCurrentLogin && _isDisableLoginButton ? buttonColor.shade200 : buttonColor,
            onTap: !_switchCurrentLogin && _isDisableLoginButton ? null : _register,
            child: Text(S.of(context).register, style: TextStyle(color: Colors.white)),
          ),
        ),
      ]),
    ]);
  }

  // 如果输入的账号密码为空则禁用登录按钮
  void _resetLoginButtonState() {
    _isDisableLoginButton = _username.isEmpty || _password.isEmpty || (_switchCurrentLogin ? false : _rPassword.isEmpty);
    setState(() => {});
  }

  // 登录按钮点击事件
  void _login() {
    FocusScope.of(context).unfocus();
    if (!_switchCurrentLogin) {
      setState(() => _switchCurrentLogin = true);
      return;
    }
    HttpsClient.instance.request(apiServices.login(_username, _password), success: (data) {
      UserEntity user = UserEntity.fromJson(data);

      // 先保存SP，数据库创建需要用到SP的userId
      SpUtil.setUserLoginState(true);
      SpUtil.setUsername(user.username);
      SpUtil.setUserId(user.id.toString());

      // 更新数据
      context.read<UserModel>().user = user;
      _pushMainPage();
    });
  }

  void _register() {
    FocusScope.of(context).unfocus();
    if (!_isLoginAndRegisterPage) {
      FocusScope.of(context).unfocus();
      RouteManager.push(context, RegisterPage());
      return;
    }
    if (_switchCurrentLogin) {
      setState(() => _switchCurrentLogin = false);
      return;
    }
  }

  void _pushMainPage() {
    RouteManager.push(context, MainPage(), clearStack: true);
  }
}
