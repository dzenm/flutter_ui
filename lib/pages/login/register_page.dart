import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../base/http/https_client.dart';
import '../../base/log/build_config.dart';
import '../../base/log/log.dart';
import '../../base/route/app_route_delegate.dart';
import '../../base/utils/sp_util.dart';
import '../../base/widgets/tap_layout.dart';
import '../../entities/user_entity.dart';
import '../../generated/l10n.dart';
import '../../models/user_model.dart';
import '../routers.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const String _tag = 'RegisterPage';

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _rPasswordController = TextEditingController();

  String _username = '';
  String _password = '';
  String _rPassword = '';

  bool _isShowPwd = false; // 是否显示输入的密码
  bool _isShowRPwd = false; // 是否显示输入的重复密码

  bool _isDisableLoginButton = true; // 是否禁用点击按钮

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
  void didUpdateWidget(covariant RegisterPage oldWidget) {
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
    log('build');

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).register, style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: _buildBody(),
      ),
    );
  }

  // 主体页面结构
  Widget _buildBody() {
    MaterialColor buttonColor = Colors.blue;
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(height: 80),
        // 用户名输入框
        TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            icon: Icon(Icons.person),
            labelText: S.of(context).username,
            suffixIcon: IconButton(
              splashColor: Colors.transparent,
              icon: Icon(Icons.close),
              onPressed: () => _usernameController.clear(),
            ),
          ),
          maxLines: 1,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          keyboardType: TextInputType.text,
        ),
        SizedBox(height: 32),
        // 密码输入框
        TextField(
          controller: _passwordController,
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
        TextField(
          controller: _rPasswordController,
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
        SizedBox(height: 32),
        Row(children: [
          // 注册按钮
          Expanded(
            flex: 1,
            child: TapLayout(
              height: 36.0,
              borderRadius: BorderRadius.all(Radius.circular(2)),
              background: _isDisableLoginButton ? buttonColor.shade200 : buttonColor,
              onTap: _isDisableLoginButton ? null : _register,
              child: Text(S.of(context).register, style: TextStyle(color: Colors.white)),
            ),
          ),
        ]),
      ]),
    );
  }

  // 如果输入的账号密码为空则禁用按钮
  void _resetButtonState() {
    setState(() => _isDisableLoginButton = _username.isEmpty || _password.isEmpty || _rPassword.isEmpty);
  }

  // 注册按钮点击事件
  void _register() {
    FocusScope.of(context).unfocus();
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

  void _pushMainPage() {
    AppRouteDelegate.of(context).push(Routers.main, clearStack: true);
  }

  void log(String msg) => BuildConfig.showPageLog ? Log.i(msg, tag: _tag) : null;
}
