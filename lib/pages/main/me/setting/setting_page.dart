import 'package:bot_toast/bot_toast.dart';
import 'package:fbl/fbl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/l10n.dart';
import '../../../../http/http_manager.dart';
import '../me_router.dart';

/// 设置页面
class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with Logging {
  bool switchState = true;

  @override
  void initState() {
    super.initState();
    logPage('initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    logPage('didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant SettingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    logPage('didUpdateWidget');
  }

  @override
  void deactivate() {
    super.deactivate();
    logPage('deactivate');
  }

  @override
  void dispose() {
    super.dispose();
    logPage('dispose');
  }

  @override
  Widget build(BuildContext context) {
    logPage('build');

    AppTheme theme = context.watch<LocalModel>().theme;
    Locale locale = context.watch<LocalModel>().locale;

    String currentVersion = BuildConfig.packageInfo.version;
    return Scaffold(
      appBar: CommonBar(
        title: S.of(context).setting,
      ),
      backgroundColor: theme.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TapLayout(
                height: 50.0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                background: theme.white,
                child: SingleTextView(
                  icon: Icons.notifications_on_sharp,
                  title: S.of(context).notification,
                  suffix: CupertinoSwitch(
                    value: switchState,
                    onChanged: (value) => setState(() => switchState = value),
                  ),
                ),
              ),
              TapLayout(
                height: 50.0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                background: theme.white,
                onTap: () => _selectedTheme(),
                child: SingleTextView(
                  icon: Icons.color_lens,
                  title: S.of(context).theme,
                  isShowForward: true,
                  suffix: Container(
                    height: 24,
                    width: 24,
                    color: theme.appbar,
                    child: const SizedBox(height: 24, width: 24),
                  ),
                ),
              ),
              TapLayout(
                height: 50.0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                background: theme.white,
                onTap: _selectedLanguage,
                child: SingleTextView(
                  icon: Icons.language,
                  title: S.of(context).language,
                  isShowForward: true,
                  text: _convertLocale(locale),
                  textAlign: TextAlign.right,
                ),
              ),
              const DividerView(height: 8),
              TapLayout(
                height: 50.0,
                background: theme.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleTextView(
                  title: S.of(context).loginRecord,
                  badgeCount: 0,
                  isShowForward: true,
                ),
              ),
              TapLayout(
                height: 50.0,
                background: theme.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onTap: () {
                  CancelFunc cancel = CommonDialog.loading();
                  Future.delayed(const Duration(seconds: 1), () {
                    CommonDialog.showToast(S.of(context).alreadyTheLatestVersion);
                    cancel();
                  });
                },
                child: SingleTextView(
                  title: S.of(context).checkUpgrade,
                  suffix: Text('v$currentVersion'),
                  badgeCount: 0,
                  isShowForward: true,
                ),
              ),
              TapLayout(
                height: 50.0,
                background: theme.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onTap: () => context.pushNamed(MeRouter.about),
                child: SingleTextView(title: S.of(context).aboutMe, isShowForward: true),
              ),
              const DividerView(height: 8),
              TapLayout(
                height: 50.0,
                background: theme.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                onTap: () => HttpManager().logout(),
                child: SingleTextView(title: S.of(context).exitLogout, isShowForward: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 主题弹窗选择
  void _selectedTheme() {
    LocalModel model = context.read<LocalModel>();
    AppTheme theme = model.theme;
    List<AppThemeMode> modes = model.themes;
    AppThemeMode currentThemeMode = model.themeMode;
    showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(S.of(context).selectTheme),
          content: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: modes.map((mode) {
                Color? value = model.getTheme(mode).appbar;
                return InkWell(
                  onTap: () {
                    model.setThemeMode(mode);
                    CommonDialog.showToast(S.of(context).successfullyModified);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    color: value,
                    child: currentThemeMode == mode ? Icon(Icons.done, color: theme.icon) : null,
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  /// 语言弹窗选择
  void _selectedLanguage() {
    List<Locale> locales = [
      const Locale('zh'),
      const Locale('en'),
    ];
    showDialog<bool>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(S.of(context).selectLanguage),
          children: locales.map((locale) {
            return SimpleDialogOption(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(_convertLocale(locale)),
              onPressed: () {
                context.read<LocalModel>().setLocale(locale);
                CommonDialog.showToast(S.of(context).successfullyModified);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  /// 转化本地语言：locale -> string
  String _convertLocale(Locale locale) {
    if (locale.languageCode == 'zh') {
      return S.of(context).chinese;
    } else if (locale.languageCode == 'en') {
      return S.of(context).english;
    }
    return S.of(context).followSystem;
  }
}
