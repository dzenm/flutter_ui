import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../application.dart';
import 'lang/lang.dart';
import 'lang/lang_en.dart';
import 'lang/lang_zh.dart';

/// 语言包
class S implements WidgetsLocalizations {
  // 当前显示的语言类型
  final Locale _locale;

  S(this._locale);

  // 语言包填充数据的widget
  static const List<LocalizationsDelegate> localizationsDelegates = [
    GeneratedLocalizationsDelegate(), // 需要设置多语言的本地值
    GlobalMaterialLocalizations.delegate, // Material库widget
    GlobalWidgetsLocalizations.delegate, // Widgets库widget
    GlobalCupertinoLocalizations.delegate, // Cupertino库widget
  ];

  // 语言包，可以指定国家编码
  static const List<Locale> supportedLocales = [
    Locale('zh'),
    Locale('en'),
  ];

  // 保证切换语言时页面能自动刷新所有页面，一定要传对应页面的context，否则不起作用
  static Lang of(BuildContext context) => Localizations.of(context, S)._getLang();

  // 在一些没有context页面时，使用全局的context。
  static Lang get from => of(Application().context);

  Lang _getLang() {
    return _langMap[_locale.languageCode]!;
  }

  Map<String, Lang> _langMap = {
    'zh': LangZh(),
    'en': LangEn(),
  };

  @override
  TextDirection get textDirection => TextDirection.ltr;
}

/// 资源加载委托工具
class GeneratedLocalizationsDelegate extends LocalizationsDelegate<S> {
  const GeneratedLocalizationsDelegate();

  /// 当Locale发生改变时（语言环境），加载对应的资源，这个方法返回的是一个Future，因为有可能是异步加载的；
  /// 但是我们这里是直接定义的一个Map，因此可以直接返回一个同步的
  @override
  Future<S> load(Locale locale) {
    // 在这里加载所需的语言包
    return SynchronousFuture<S>(S(locale));
  }

  /// 当前环境的Locale，是否在我们支持的语言范围
  @override
  bool isSupported(Locale locale) {
    for (Locale supportedLocale in S.supportedLocales) {
      // Language must always match both locales.
      if (supportedLocale.languageCode != locale.languageCode) {
        continue;
      }

      // If country code matches, return this locale.
      if (supportedLocale.countryCode == locale.countryCode) {
        return true;
      }
    }
    return false;
  }

  /// 当Localizations Widget重新build时，是否调用load方法重新加载Locale资源
  /// 一般情况下，Locale资源在Locale切换时加载一次，不需要每次Localizations重新build时都加载一遍；返回false即可
  @override
  bool shouldReload(GeneratedLocalizationsDelegate old) => false;
}
