import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// 设置语言包
class S implements WidgetsLocalizations {
  // 当前显示的语言类型
  final Locale _locale;

  S(this._locale);

  // 创建语言包配置
  static const GeneratedLocalizationsDelegate delegate = GeneratedLocalizationsDelegate();

  // 支持的语言包
  static const List<Locale> supportedLocales = [
    Locale('zh'),
    Locale('en'),
  ];

  static S of(BuildContext context) => Localizations.of(context, S);

  @override
  TextDirection get textDirection => TextDirection.ltr;

  // 语言包
  static Map<String, Map<String, String>> localizedValues = {
    'zh': {
      // 登录注册模块
      'login': '登录',
      'register': '注册',
      'username': '用户名',
      'phone': '手机号',
      'email': '邮箱',
      'password': '密码',
      'setting': '设置',
      'theme': '主题',
      'language': '语言',
      'logout': '注销',
      'exit': '退出',
      // 主页模块
      'home': '首页',
      'me': '我',
      // 未找到路由模块
      'pageIsNotFound': '页面未找到',
      'pageIsNotFoundPleaseCheckIt': '页面未找到，请检查是否注册',
      // 其他模块
      'textAndInput': '文本和输入框',
      'navigationBar': 'NavigationBar',
      'charConvert': '字符转化',
      'httpRequest': 'Http请求',
      'listAndRefresh': '列表和刷新',
    },
    'en': {
      // 登录注册，个人中心，设置模块
      'login': 'Login',
      'register': 'Register',
      'username': 'Username',
      'phone': 'Phone',
      'email': 'Email',
      'password': 'Password',
      'setting': 'Setting',
      'theme': 'Theme',
      'language': 'Language',
      'logout': 'Logout',
      'exit': 'Exit',
      // 主页模块
      'home': 'home',
      'me': 'me',
      // 未找到路由模块
      'pageIsNotFound': 'Page is not found',
      'pageIsNotFoundPleaseCheckIt': 'Page is not found, please check it',
      // 其他模块
      'textAndInput': 'Text And Input',
      'navigationBar': 'NavigationBar',
      'charConvert': 'Character Convert',
      'httpRequest': 'Http Request',
      'listAndRefresh': 'List And Refresh',
    },
  };

  Map<String, String> get _values => localizedValues[_locale.languageCode]!;

  // 登录注册模块
  String get login => _values['login']!;

  String get register => _values['register']!;

  String get username => _values['username']!;

  String get password => _values['password']!;

  String get phone => _values['phone']!;

  String get email => _values['email']!;

  String get setting => _values['setting']!;

  String get theme => _values['theme']!;

  String get language => _values['language']!;

  String get logout => _values['logout']!;

  String get exit => _values['exit']!;

  // 主页模块
  String get home => _values['home']!;

  String get me => _values['me']!;

  // 未找到路由模块
  String get pageIsNotFound => _values['pageIsNotFoundPleaseCheckIt']!;

  String get pageIsNotFoundPleaseCheckIt => _values['pageIsNotFoundPleaseCheckIt']!;

  // 其他模块
  String get textAndInput => _values['textAndInput']!;

  String get navigationBar => _values['navigationBar']!;

  String get charConvert => _values['charConvert']!;

  String get httpRequest => _values['httpRequest']!;

  String get listAndRefresh => _values['listAndRefresh']!;
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
  bool isSupported(Locale locale) => _isSupported(locale, true);

  /// Returns true if the specified locale is supported, false otherwise.
  bool _isSupported(Locale locale, bool withCountry) {
    for (Locale supportedLocale in S.supportedLocales) {
      // Language must always match both locales.
      if (supportedLocale.languageCode != locale.languageCode) {
        continue;
      }

      // If country code matches, return this locale.
      if (supportedLocale.countryCode == locale.countryCode) {
        return true;
      }

      // If no country requirement is requested, check if this locale has no country.
      if (!withCountry && (supportedLocale.countryCode == null || supportedLocale.countryCode!.isEmpty)) {
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
