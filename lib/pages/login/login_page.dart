import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../base/http/https_client.dart';
import '../../base/log/build_config.dart';
import '../../base/log/log.dart';
import '../../base/res/app_theme.dart';
import '../../base/res/local_model.dart';
import '../../base/route/app_route_delegate.dart';
import '../../base/utils/sp_util.dart';
import '../../base/widgets/common_bar.dart';
import '../../base/widgets/common_dialog.dart';
import '../../base/widgets/tap_layout.dart';
import '../../entities/user_entity.dart';
import '../../generated/l10n.dart';
import '../../models/user_model.dart';
import '../routers.dart';

///
/// 登录页面
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
    return Material(
      child: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const _EditLoginInfoView(),
            Expanded(child: Container()),
            const ProtocolInfoView(),
            const SizedBox(height: 72),
          ]),
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
  static bool _isAgree = false;

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
  bool _loginByPhone = true; // 是否通过手机号验证码登录
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
  }

  // 初始化输入框的内容，如果本地储存账号和密码，获取并填充到输入框
  void _initInputText() {
    _usernameController.text = _username = SpUtil.getUsername();
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
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
      if (!_loginByPhone)
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
      // 验证码输入框
      if (_loginByPhone)
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            icon: const Icon(Icons.verified_sharp),
            labelText: S.of(context).verifyCode,
            suffix: const VerifyCodeView(),
          ),
          maxLines: 1,
          keyboardType: TextInputType.text,
          obscureText: !_isShowPwd,
        ),
      const SizedBox(height: 40),

      // 登陆按钮
      TapLayout(
        height: 40.0,
        borderRadius: const BorderRadius.all(Radius.circular(2)),
        background: _isDisableLoginButton ? theme.disableButton : theme.button,
        onTap: _isDisableLoginButton ? null : _login,
        child: Text(S.of(context).login, style: TextStyle(color: theme.text)),
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
            Text(
              '${_loginByPhone ? S.of(context).verifyCode : S.of(context).password}${S.of(context).login}',
              style: TextStyle(color: theme.button),
            ),
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
            Text(S.of(context).register, style: TextStyle(color: theme.button)),
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
  }

  /// 登录按钮点击事件
  void _login() {
    FocusScope.of(context).unfocus();
    if (!_EditLoginInfoView._isAgree) {
      CommonDialog.showToast('请先同意隐私协议');
      return;
    }
    String password = '';
    if (!_loginByPhone) {
      password = _password;
    } else {
      password = _verifyCode;
    }
    HttpsClient.instance.request(apiServices.login(_username, password), success: (data) {
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
    AppRouteDelegate.of(context).push(Routers.register);
  }

  void _pushMainPage() {
    AppRouteDelegate.of(context).push(Routers.main, clearStack: true);
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
  bool _isAgree = _EditLoginInfoView._isAgree;

  @override
  Widget build(BuildContext context) {
    AppTheme theme = context.watch<LocalModel>().theme;
    IconData icon = _isAgree ? Icons.check_box_sharp : Icons.check_box_outline_blank_sharp;
    Color color = _isAgree ? theme.blue : theme.hint;
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(width: 16),
        TapLayout(
          foreground: theme.transparent,
          padding: const EdgeInsets.all(8),
          onTap: () {
            setState(() => _isAgree = !_isAgree);
            _EditLoginInfoView._isAgree = _isAgree;
          },
          child: Icon(icon, color: color),
        ),
        Text(S.of(context).readAndAgree, style: TextStyle(color: theme.hint, fontSize: 12)),
        TapLayout(
          onTap: () {},
          child: Text(S.of(context).registerProtocol, style: TextStyle(color: theme.blue, fontSize: 12)),
        ),
        TapLayout(
          onTap: () {},
          child: Text(S.of(context).privateProtocol, style: TextStyle(color: theme.blue, fontSize: 12)),
        ),
        const SizedBox(width: 16),
      ]),
    ]);
  }
}

/// 验证码
class VerifyCodeView extends StatefulWidget {
  final GestureTapCallback? onTap;

  const VerifyCodeView({super.key, this.onTap});

  @override
  State<StatefulWidget> createState() => _VerifyCodeViewState();
}

class _VerifyCodeViewState extends State<VerifyCodeView> {
  Timer? _timer; // 计时器
  int _second = -1; // 计时的时间

  /// 倒计时
  void _countDownCode() {
    _second = 59;
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
    bool reset = _second < 0;
    String text = reset ? '获取验证码' : '$_second 秒';
    return Row(mainAxisSize: MainAxisSize.min, children: [
      TapLayout(
        background: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        onTap: reset
            ? null
            : () {
                _countDownCode();
                if (widget.onTap != null) {
                  widget.onTap!();
                }
              },
        child: Text(text),
      ),
    ]);
  }
}
