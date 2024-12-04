import 'package:fbl/fbl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../http/http_manager.dart';
import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformView.builder(
      mobileView: _buildAppPage(context),
      desktopView: _buildDeskTopPage(context),
      webView: _buildWebPage(context),
    );
  }

  /// Web网页端展示的页面
  Widget _buildWebPage(BuildContext context) {
    return Material(
      child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: const _EditRegisterInfoView(),
        ),
      ),
    );
  }

  /// Desktop桌面端展示的页面
  Widget _buildDeskTopPage(BuildContext context) {
    return Material(
      child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: const _EditRegisterInfoView(),
        ),
      ),
    );
  }

  /// App移动端展示的页面
  Widget _buildAppPage(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    Size size = MediaQuery.of(context).size;
    double marginTop = size.height / 14;
    double marginBottom = size.height / 6;
    return Scaffold(
      backgroundColor: theme.background,
      body: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CommonBar(
            titleColor: theme.primaryText,
            backgroundColor: theme.background,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.dark,
            ),
          ),
          SizedBox(height: marginTop),
          Container(
            padding: const EdgeInsets.all(24),
            child: const _EditRegisterInfoView(),
          ),
          SizedBox(height: marginBottom),
          const ProtocolInfoView(),
        ]),
      ),
    );
  }
}

class _EditRegisterInfoView extends StatefulWidget {
  const _EditRegisterInfoView();

  @override
  State<StatefulWidget> createState() => __EditRegisterInfoViewState();
}

class __EditRegisterInfoViewState extends State<_EditRegisterInfoView> with Logging {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rPasswordController = TextEditingController();

  String _username = '';
  String _password = '';
  String _rPassword = '';

  bool _isShowPwd = false; // 是否显示输入的密码
  bool _isShowRPwd = false; // 是否显示输入的重复密码

  bool _isDisableLoginButton = true; // 是否禁用点击按钮

  @override
  void initState() {
    super.initState();
    logPage('initState');

    _initInputText();
  }

  @override
  void dispose() {
    super.dispose();
    logPage('dispose');

    _usernameController.dispose();
    _passwordController.dispose();
    _rPasswordController.dispose();
  }

  // 初始化输入框的内容并监听输入的内容
  void _initInputText() {
    _usernameController.addListener(() {
      _username = _usernameController.text;
      _resetButtonState();
    });
    _passwordController.addListener(() {
      _password = _passwordController.text;
      _resetButtonState();
    });
    _rPasswordController.addListener(() {
      _rPassword = _rPasswordController.text;
      _resetButtonState();
    });
  }

  @override
  Widget build(BuildContext context) {
    logPage('build');

    AppTheme theme = context.watch<LocalModel>().theme;
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const SizedBox(height: 80),
      // 用户名输入框
      TextField(
        controller: _usernameController,
        decoration: InputDecoration(
          icon: const Icon(Icons.person),
          labelText: S.of(context).username,
          suffixIcon: IconButton(
            splashColor: theme.transparent,
            icon: const Icon(Icons.close),
            onPressed: () => _usernameController.clear(),
          ),
        ),
        maxLines: 1,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        keyboardType: TextInputType.text,
      ),
      const SizedBox(height: 32),
      // 密码输入框
      TextField(
        controller: _passwordController,
        decoration: InputDecoration(
          icon: const Icon(Icons.admin_panel_settings),
          labelText: S.of(context).password,
          suffixIcon: IconButton(
            splashColor: theme.transparent,
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
      const SizedBox(height: 32),
      // 重复密码输入框
      TextField(
        controller: _rPasswordController,
        decoration: InputDecoration(
          icon: const Icon(Icons.admin_panel_settings),
          labelText: S.of(context).rPassword,
          suffixIcon: IconButton(
            splashColor: theme.transparent,
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
      const SizedBox(height: 32),
      Row(children: [
        // 注册按钮
        Expanded(
          flex: 1,
          child: TapLayout(
            height: 36.0,
            borderRadius: const BorderRadius.all(Radius.circular(2)),
            background: _isDisableLoginButton ? theme.disableButton : theme.button,
            onTap: _isDisableLoginButton ? null : _register,
            child: Text(S.of(context).register, style: TextStyle(color: theme.text)),
          ),
        ),
      ]),
    ]);
  }

  // 如果输入的账号密码为空则禁用按钮
  void _resetButtonState() {
    setState(() => _isDisableLoginButton = _username.isEmpty || _password.isEmpty || _rPassword.isEmpty);
  }

  // 注册按钮点击事件
  void _register() {
    FocusScope.of(context).unfocus();
    HttpManager().register(_username, _password, _rPassword);
  }
}
