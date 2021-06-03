import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/base/res/assets.dart';
import 'package:flutter_ui/base/res/colors.dart';
import 'package:flutter_ui/base/res/local_model.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/base/widgets/common_widget.dart';
import 'package:flutter_ui/base/widgets/single_text_layout.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/models/provider_model.dart';

class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  TextEditingController _controller = new TextEditingController(text: "初始化");
  String text = '';
  String newText = '';
  bool switchState = true;
  String _colorKey = LocalModel().themeColor;

  @override
  void initState() {
    super.initState();
    newText = text = _controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置', style: TextStyle(color: Colors.white)),
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
                onTap: () => showToast('用户名'),
                child: SingleTextLayout(icon: Icons.person, title: '用户名', text: '知晓', isTextLeft: false, isShowForward: true),
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
                onTap: () => showToast('手机号码'),
                child: SingleTextLayout(icon: Icons.phone_android, title: '手机号', text: '17601487212', isTextLeft: false, isShowForward: true),
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
                  title: '主题',
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
                onTap: _selectedTheme,
                child: SingleTextLayout(
                  icon: Icons.language,
                  title: '语言',
                  isShowForward: true,
                  text: '跟随系统',
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
                onTap: () => showToast('注销'),
                child: SingleTextLayout(title: '注销', isShowForward: true),
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
                child: SingleTextLayout(title: '退出', isShowForward: true),
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
    ).then((value) => showToast('设置成功'));
  }
}
