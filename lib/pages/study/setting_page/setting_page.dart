import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui/base/http/http_client.dart';
import 'package:flutter_ui/base/log/log.dart';
import 'package:flutter_ui/base/res/local_model.dart';
import 'package:flutter_ui/base/res/assets.dart';
import 'package:flutter_ui/base/res/colors.dart';
import 'package:flutter_ui/base/res/strings.dart';
import 'package:flutter_ui/base/res/theme/app_theme.dart';
import 'package:flutter_ui/base/router/route_manager.dart';
import 'package:flutter_ui/base/utils/sp_util.dart';
import 'package:flutter_ui/base/widgets/common_dialog.dart';
import 'package:flutter_ui/base/widgets/common_widget.dart';
import 'package:flutter_ui/base/widgets/single_text_layout.dart';
import 'package:flutter_ui/base/widgets/tap_layout.dart';
import 'package:flutter_ui/entities/user_entity.dart';
import 'package:flutter_ui/models/provider_manager.dart';
import 'package:flutter_ui/models/user_model.dart';
import 'package:flutter_ui/pages/common/preview_photo_page.dart';
import 'package:flutter_ui/pages/login/login_page.dart';
import 'package:provider/provider.dart';

import '../study_model.dart';

/// 设置页面
class SettingPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  static const String _tag = 'SettingPage';

  bool switchState = true;

  @override
  void initState() {
    super.initState();
    Log.i('initState', tag: _tag);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Log.i('didChangeDependencies', tag: _tag);
  }

  @override
  void didUpdateWidget(covariant SettingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    Log.d('didUpdateWidget', tag: _tag);
  }

  @override
  void deactivate() {
    super.deactivate();
    Log.d('deactivate', tag: _tag);
  }

  @override
  void dispose() {
    super.dispose();
    Log.d('dispose', tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    Log.d('build', tag: _tag);

    AppTheme appTheme = context.watch<LocalModel>().appTheme;
    Locale locale = context.watch<LocalModel>().locale;
    UserEntity user = context.watch<UserModel>().user;
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
              // 展示用户名
              TapLayout(
                isRipple: false,
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: () => CommonDialog.showToast(S.of(context).username),
                child: SingleTextLayout(
                  icon: Icons.person,
                  title: S.of(context).username,
                  text: user.username,
                  isTextLeft: false,
                  isShowForward: true,
                ),
              ),
              // 展示用户头像
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: () => PreviewPhotoPage.show([
                  "https://www.wanandroid.com/blogimgs/50c115c2-cf6c-4802-aa7b-a4334de444cd.png",
                  Assets.image('a.jpg'),
                  Assets.image('a.jpg'),
                ]),
                child: SingleTextLayout(
                  icon: Icons.error,
                  title: S.of(context).avatar,
                  isTextLeft: false,
                  suffix: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(Assets.image('a.jpg'), fit: BoxFit.cover, width: 24, height: 24),
                  ),
                  isShowForward: true,
                ),
              ),
              // 展示用户ID
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: () => context.read<StudyModel>().setValue('new value'),
                child: SingleTextLayout(
                  icon: Icons.phone_android,
                  title: S.of(context).phone,
                  text: user.id.toString(),
                  isTextLeft: false,
                  isShowForward: true,
                ),
              ),
              // 展示用户邮箱
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: () => context.read<StudyModel>().setValue('new value'),
                child: SingleTextLayout(
                  icon: Icons.email,
                  title: S.of(context).email,
                  text: user.email,
                  isTextLeft: false,
                  isShowForward: true,
                ),
              ),
              // 展示用户邮箱
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: () => context.read<StudyModel>().setValue('new value'),
                child: SingleTextLayout(
                  icon: Icons.money,
                  title: S.of(context).coin,
                  text: user.coinCount.toString(),
                  isTextLeft: false,
                  isShowForward: true,
                ),
              ),
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: () {
                  CancelFunc cancel = CommonDialog.loading();
                  Future.delayed(Duration(seconds: 1), () => cancel());
                },
                child: SingleTextLayout(
                  icon: Icons.verified,
                  title: S.of(context).verifyPhone,
                  isShowForward: true,
                  badgeCount: 0,
                ),
              ),
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SingleTextLayout(
                  icon: Icons.notifications_on_sharp,
                  title: S.of(context).notificationSwitch,
                  suffix:
                      CupertinoSwitch(value: switchState, onChanged: (value) => setState(() => switchState = value)),
                ),
              ),
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: () => _selectedTheme(),
                child: SingleTextLayout(
                  icon: Icons.color_lens,
                  title: S.of(context).theme,
                  isShowForward: true,
                  suffix: Container(
                    height: 24,
                    width: 24,
                    color: appTheme.primary,
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
                  text: _convertLocale(locale),
                  isTextLeft: false,
                ),
              ),
              CommonWidget.divider(height: 8),
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: () => context.read<LocalModel>().setValue('new value'),
                child: SingleTextLayout(title: S.of(context).loginRecord, badgeCount: 0, isShowForward: true),
              ),
              TapLayout(
                height: 50.0,
                padding: EdgeInsets.symmetric(horizontal: 16),
                onTap: () {
                  CancelFunc cancel = CommonDialog.loading();
                  Future.delayed(Duration(seconds: 1), () {
                    CommonDialog.showToast('已是最新版本');
                    cancel();
                  });
                },
                child: SingleTextLayout(title: S.of(context).checkUpgrade, badgeCount: 100, isShowForward: true),
              ),
              CommonWidget.divider(height: 8),
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
                  CancelFunc cancel = CommonDialog.loading();
                  Future.delayed(Duration(seconds: 1), () {
                    CommonDialog.showToast('退出成功');
                    cancel();
                  });
                },
                child: SingleTextLayout(
                  image: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(Assets.image('a.jpg'), fit: BoxFit.cover, width: 24, height: 24),
                  ),
                  title: S.of(context).exit,
                  isShowForward: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectedTheme() {
    String theme = context.read<LocalModel>().theme;
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(S.of(context).selectTheme),
          content: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: C.getKeys().map((key) {
                Color? value = C.getTheme(key).primary;
                return InkWell(
                  onTap: () {
                    context.read<LocalModel>().setTheme(key);
                    CommonDialog.showToast('修改成功');
                    RouteManager.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    color: value,
                    child: theme == key ? Icon(Icons.done, color: Colors.white) : null,
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
          title: Text(S.of(context).selectLanguage),
          children: S.supportedLocales.map((value) {
            return SimpleDialogOption(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(_convertLocale(value)),
              onPressed: () {
                context.read<LocalModel>().setLocale(value);
                CommonDialog.showToast('修改成功');
                RouteManager.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  String _convertLocale(Locale locale) {
    if (locale.languageCode == 'zh') {
      return S.of(context).chinese;
    } else if (locale.languageCode == 'en') {
      return S.of(context).english;
    }
    return S.of(context).followSystem;
  }

  void _logout() {
    HttpClient.instance.request(apiServices.logout(), success: (data) {
      SpUtil.resetUser();
      ProviderManager.clear(context);
      RouteManager.push(context, LoginPage(), clearStack: true);
    });
  }
}
