import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/http/api_client.dart';
import 'package:flutter_ui/base/res/assets.dart';
import 'package:flutter_ui/base/res/colors.dart';
import 'package:flutter_ui/base/res/strings.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/base/widgets/common_widget.dart';
import 'package:flutter_ui/base/widgets/single_text_layout.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/models/provider_model.dart';
import 'package:flutter_ui/pages/login/login_route.dart';
import 'package:flutter_ui/router/navigator_manager.dart';
import 'package:flutter_ui/utils/sp_util.dart';

class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  TextEditingController _controller = new TextEditingController(text: "init");
  String text = '';
  String newText = '';
  bool switchState = true;
  late String _colorKey;
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _colorKey = ProviderManager.localModel(context).theme;
    _locale = ProviderManager.localModel(context).locale;
    newText = text = _controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).setting, style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: () => showToast(S.of(context).username),
                child: SingleTextLayout(icon: Icons.person, title: S.of(context).username, text: '知晓', isTextLeft: false, isShowForward: true),
              ),
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: () => showToast('设置头像'),
                child: SingleTextLayout(
                  icon: Icons.error,
                  title: '头像',
                  isTextLeft: false,
                  suffix: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(Assets.image('a.jpg'), fit: BoxFit.cover, width: 24, height: 24),
                  ),
                  isShowForward: true,
                ),
              ),
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: () => showToast(S.of(context).phone),
                child: SingleTextLayout(icon: Icons.phone_android, title: S.of(context).phone, text: '17601487212', isTextLeft: false, isShowForward: true),
              ),
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: () {
                  CancelFunc cancel = loadingDialog();
                  Future.delayed(Duration(seconds: 1), () => cancel());
                },
                child: SingleTextLayout(
                  icon: Icons.verified,
                  title: '验证手机号',
                  isTextLeft: false,
                  isShowForward: true,
                  badgeCount: 0,
                ),
              ),
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SingleTextLayout(
                  icon: Icons.notifications_on_sharp,
                  title: '通知开关',
                  suffix: CupertinoSwitch(value: switchState, onChanged: (value) => setState(() => switchState = value)),
                ),
              ),
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: _selectedTheme,
                child: SingleTextLayout(
                  icon: Icons.color_lens,
                  title: S.of(context).theme,
                  isShowForward: true,
                  suffix: Container(
                    height: 24,
                    width: 24,
                    color: themeColorModel[_colorKey]!['primaryColor'],
                    child: SizedBox(height: 24, width: 24),
                  ),
                ),
              ),
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: _selectedLanguage,
                child: SingleTextLayout(
                  icon: Icons.language,
                  title: S.of(context).language,
                  isShowForward: true,
                  text: _convertLocale(_locale),
                  isTextLeft: false,
                ),
              ),
              divider(height: 8),
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: () => showToast('异常登录记录'),
                child: SingleTextLayout(title: '登录记录', badgeCount: 0, isShowForward: true),
              ),
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: () {
                  CancelFunc cancel = loadingDialog();
                  Future.delayed(Duration(seconds: 1), () {
                    showToast('已是最新版本');
                    cancel();
                  });
                },
                child: SingleTextLayout(title: '检查更新', badgeCount: 100, isShowForward: true),
              ),
              divider(height: 8),
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: _logout,
                child: SingleTextLayout(title: S.of(context).logout, isShowForward: true),
              ),
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: () {
                  CancelFunc cancel = loadingDialog();
                  Future.delayed(Duration(seconds: 1), () {
                    showToast('退出成功');
                    cancel();
                  });
                },
                child: SingleTextLayout(title: S.of(context).exit, isShowForward: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectedTheme() {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('选择主题'),
          content: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: themeColorModel.keys.map((key) {
                Color? value = themeColorModel[key]!['primaryColor'];
                return InkWell(
                  onTap: () {
                    setState(() => _colorKey = key);
                    ProviderManager.localModel(context).setTheme(key);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    color: value,
                    child: _colorKey == key ? Icon(Icons.done, color: Colors.white) : null,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _selectedLanguage() {
    showDialog<bool>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('选择语言'),
          children: S.supportedLocales.map((value) {
            return SimpleDialogOption(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(_convertLocale(value)),
              onPressed: () {
                setState(() => _locale = value);
                ProviderManager.localModel(context).setLocale(value);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  String _convertLocale(Locale locale) {
    if (locale.languageCode == 'zh') {
      return '简体中文';
    } else if (locale.languageCode == 'en') {
      return '美国英语';
    }
    return '跟随系统';
  }

  void _logout() {
    ApiClient.instance.request(apiServices.logout(), success: (data) {
      SpUtil.setIsLogin(false);
      SpUtil.setUserId(null);
      SpUtil.setToken(null);

      NavigatorManager.push(context, LoginRoute.login, clearStack: true);
    });
  }
}
