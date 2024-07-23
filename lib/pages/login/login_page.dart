import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../base/a_router/misc/extensions.dart';
import '../../base/base.dart';
import '../../generated/l10n.dart';
import '../../http/http_manager.dart';
import '../routers.dart';

///
/// 登录页面
class LoginPage extends StatelessWidget {
  LoginPage({super.key}) {
    DesktopWrapper.setWindow(
      size: const Size(400, 600),
      minimumSize: const Size(400, 600),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (BuildConfig.isWeb) {
      return _buildWebPage(context);
    } else if (BuildConfig.isDesktop) {
      return _buildDeskTopPage(context);
    }
    return _buildAppPage(context);
  }

  /// Web网页端展示的页面
  Widget _buildWebPage(BuildContext context) {
    return Material(
      child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: const _EditLoginInfoView(),
        ),
      ),
    );
  }

  /// Desktop桌面端展示的页面
  Widget _buildDeskTopPage(BuildContext context) {
    return DesktopWrapper(
      showMoveBar: true,
      child: Material(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const SizedBox(height: 72),
              const _EditLoginInfoView(),
              Expanded(child: Container()),
              const ProtocolInfoView(),
              const SizedBox(height: 72),
            ]),
          ),
        ),
      ),
    );
  }

  /// App移动端展示的页面
  Widget _buildAppPage(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    Size size = MediaQuery.of(context).size;
    double marginTop = size.height / 8;
    double marginBottom = size.height / 6;
    return Scaffold(
      backgroundColor: theme.background,
      body: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          CommonBar(
            backgroundColor: theme.background,
            systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.dark,
            ),
          ),
          SizedBox(height: marginTop),
          Container(
            padding: const EdgeInsets.all(24),
            child: const _EditLoginInfoView(),
          ),
          SizedBox(height: marginBottom),
          const ProtocolInfoView(),
        ]),
      ),
    );
  }
}

/// 登录组件主体部分(编辑登录信息)，不包含 [Scaffold]
class _EditLoginInfoView extends StatefulWidget {
  const _EditLoginInfoView();

  @override
  State<StatefulWidget> createState() => _EditLoginInfoViewState();
}

class _EditLoginInfoViewState extends State<_EditLoginInfoView> {
  static const String _tag = 'LoginPage';

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _verifyCodeController = TextEditingController();

  String _username = '';
  String _password = '';
  String _verifyCode = ''; // 验证码

  bool _isShowPwd = false; // 是否显示输入的密码
  bool _loginByPhone = false; // 是否通过手机号验证码登录
  bool _isDisableLoginButton = true; // 是否禁用点击按钮，根据输入的内容_isLogin为true禁用登陆按钮，为false禁用注册按钮

  @override
  void initState() {
    super.initState();
    log('initState');

    _initInputText();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    log('didChangeDependencies');
  }

  @override
  void didUpdateWidget(_EditLoginInfoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('didUpdateWidget');
  }

  @override
  void deactivate() {
    super.deactivate();
    log('deactivate');
  }

  @override
  void dispose() {
    super.dispose();
    log('dispose');

    _usernameController.dispose();
    _passwordController.dispose();
    _verifyCodeController.dispose();
  }

  // 初始化输入框的内容，如果本地储存账号和密码，获取并填充到输入框
  void _initInputText() {
    _usernameController.text = _username = SPManager.getUsername();
    _usernameController.addListener(() {
      _username = _usernameController.text;
      _resetLoginButtonState();
    });
    _passwordController.addListener(() {
      _password = _passwordController.text;
      _resetLoginButtonState();
    });
    _verifyCodeController.addListener(() {
      _verifyCode = _verifyCodeController.text;
      _resetLoginButtonState();
    });
  }

  @override
  Widget build(BuildContext context) {
    log('build');

    AppTheme theme = context.watch<LocalModel>().theme;
    String usernameText = S.of(context).username;
    String passwordText = S.of(context).password;
    String verifyText = S.of(context).verifyCode;
    String loginText = S.of(context).login;
    String registerText = S.of(context).register;
    String text = '${_loginByPhone ? passwordText : verifyText}$loginText';

    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      // 用户名输入框
      TextField(
        controller: _usernameController,
        decoration: InputDecoration(
          icon: const Icon(Icons.person),
          labelText: usernameText,
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
      if (!_loginByPhone)
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            icon: const Icon(Icons.admin_panel_settings),
            labelText: passwordText,
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
      // 验证码输入框
      if (_loginByPhone)
        TextField(
          controller: _verifyCodeController,
          decoration: InputDecoration(
            icon: const Icon(Icons.verified_sharp),
            labelText: verifyText,
            suffix: const VerifyCodeView(),
          ),
          maxLines: 1,
          keyboardType: TextInputType.number,
        ),
      const SizedBox(height: 40),

      // 登陆按钮
      TapLayout(
        height: 40.0,
        borderRadius: const BorderRadius.all(Radius.circular(2)),
        background: _isDisableLoginButton ? theme.disableButton : theme.button,
        onTap: _isDisableLoginButton ? null : _login,
        child: Text(loginText, style: TextStyle(color: theme.text)),
      ),
      const SizedBox(height: 16, width: 64),
      Row(children: [
        // 验证码登录按钮
        TapLayout(
          height: 40.0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          onTap: _switchLoginType,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(text, style: TextStyle(color: theme.button)),
          ]),
        ),
        Expanded(child: Container()),
        // 注册按钮
        TapLayout(
          height: 40.0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          onTap: _register,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(registerText, style: TextStyle(color: theme.button)),
          ]),
        ),
      ]),
    ]);
  }

  /// 如果输入的账号密码为空则禁用登录按钮
  void _resetLoginButtonState() {
    _isDisableLoginButton = _username.isEmpty || _password.isEmpty;
    setState(() => {});
  }

  /// 切换登录的方式
  void _switchLoginType() {
    setState(() => _loginByPhone = !_loginByPhone);
    _passwordController.clear();
    _verifyCodeController.clear();
  }

  /// 登录按钮点击事件
  void _login() {
    FocusScope.of(context).unfocus();
    if (!_ProtocolInfoViewState._isAgree) {
      CommonDialog.showToast('请先同意隐私协议');
      return;
    }
    String password = '';
    if (!_loginByPhone) {
      password = _password;
    } else {
      password = _verifyCode;
    }
    HttpManager().login(_username, password);
  }

  void _register() {
    FocusScope.of(context).unfocus();
    context.pushNamed(Routers.register);
  }

  void log(String msg) => Log.p(msg, tag: _tag);
}

/// 协议信息部分
class ProtocolInfoView extends StatefulWidget {
  const ProtocolInfoView({super.key});

  @override
  State<StatefulWidget> createState() => _ProtocolInfoViewState();
}

class _ProtocolInfoViewState extends State<ProtocolInfoView> {
  static bool _isAgree = false;
  final TapGestureRecognizer _registerRecognizer = TapGestureRecognizer();
  final TapGestureRecognizer _privateRecognizer = TapGestureRecognizer();

  @override
  void dispose() {
    _registerRecognizer.dispose();
    _privateRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('build: ProtocolInfoView(isAgree=$_isAgree)');

    AppTheme theme = context.watch<LocalModel>().theme;
    IconData icon = _isAgree ? Icons.check_box_sharp : Icons.check_box_outline_blank_sharp;
    Color color = _isAgree ? theme.checked : theme.unchecked;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        const SizedBox(width: 16),
        TapLayout(
          foreground: theme.transparent,
          padding: const EdgeInsets.all(4),
          onTap: () {
            setState(() => _isAgree = !_isAgree);
          },
          child: Icon(icon, color: color, size: 24),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(children: [
              TextSpan(text: S.of(context).readAndAgree, style: TextStyle(color: theme.hint, fontSize: 12)),
              TextSpan(
                text: S.of(context).registerProtocol,
                style: TextStyle(color: theme.signText, fontSize: 12),
                recognizer: _registerRecognizer
                  ..onTap = () {
                    CommonDialog.showToast('隐私协议');
                  },
              ),
              TextSpan(
                text: S.of(context).privateProtocol,
                style: TextStyle(color: theme.signText, fontSize: 12),
                recognizer: _privateRecognizer
                  ..onTap = () {
                    CommonDialog.showToast('隐私协议');
                  },
              ),
            ]),
          ),
        ),
        const SizedBox(width: 16),
      ]),
    ]);
  }

  void log(String msg) => Log.p(msg, tag: 'LoginPage');
}

/// 验证码
class VerifyCodeView extends StatefulWidget {
  final GestureTapCallback? onTap;

  const VerifyCodeView({super.key, this.onTap});

  @override
  State<StatefulWidget> createState() => _VerifyCodeViewState();
}

class _VerifyCodeViewState extends State<VerifyCodeView> {
  static const countDownSeconds = 59;
  Timer? _timer; // 计时器
  int _second = -1; // 计时的时间

  /// 倒计时
  void _countDownCode() {
    _second = countDownSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      --_second;
      if (_second < 0) {
        timer.cancel();
      }
      setState(() {});
    });
    setState(() {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('build: VerifyCodeView(second=$_second)');

    bool isReset = _second < 0;
    String text = isReset ? '获取验证码' : '$_second 秒';

    void Function()? onTap;
    if (isReset) {
      onTap = () {
        _countDownCode();
        if (widget.onTap != null) {
          widget.onTap!();
        }
      };
    }
    return Row(mainAxisSize: MainAxisSize.min, children: [
      TapLayout(
        background: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: onTap,
        child: Text(text),
      ),
    ]);
  }

  void log(String msg) => Log.p(msg, tag: 'LoginPage');
}
