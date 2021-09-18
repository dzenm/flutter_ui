import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/main.dart';

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

  // static S of(BuildContext context) => Localizations.of(context, S);

  static S get of => Localizations.of(Application.context, S);

  @override
  TextDirection get textDirection => TextDirection.ltr;

  // 语言包
  static Map<String, Map<String, String>> localizedValues = {
    'zh': {
      // 登录注册模块
      // 主页模块
      // 未找到路由模块
      'pageIsNotFound': '页面未找到',
      'pageIsNotFoundPleaseCheckIt': '页面未找到，请检查是否注册',
      // 其他模块
      'textAndInput': '文本和输入框',
      'navigationBar': 'NavigationBar',
      'charConvert': '字符转化',
      'httpRequest': 'Http请求',
      'citySelected': '城市选择',
      'listAndRefresh': '列表和刷新',
      'dragList': '拖拽列表',
      'videoPlay': '视频播放',
      'verifyPhone': '验证手机号',
      'notificationSwitch': '通知开关',
      'selectTheme': '选择主题',
      'selectLanguage': '选择语言',
      'followSystem': '跟随系统',
      'loginRecord': '登录记录',
      'checkUpgrade': '检查更新',
      'loadEmpty': '加载为空',
      'loadMore': '加载更多',
      'loadSuccess': '加载成功',
      'loadComplete': '加载完成',
      'loadFailed': '加载失败',
      'loadEnd': '滑动到最底部了',
      'vlcVideoPlay': 'Vlc视频播放器',
      'ijkVideoPlay': 'Ijk视频播放器',
      // 通用文本
      'login': '登录',
      'register': '注册',
      'username': '用户名',
      'phone': '手机号',
      'avatar': '头像',
      'email': '邮箱',
      'password': '密码',
      'setting': '设置',
      'theme': '主题',
      'language': '语言',
      'chinese': '简体中文',
      'english': '美国英语',
      'logout': '注销',
      'exit': '退出',
      'home': '首页',
      'me': '我',
      'state': '状态',
      'loading': '加载中',
      'confirm': '确定',
      'cancel': '取消',
      'camera': '拍照',
      'gallery': '相册',
      'qr': '二维码',
      'navigation': '导航',
      'walk': '步行',
      'keyword': '键盘',
      'unknown': '未知',
      'none': '',
    },
    'en': {
      // 登录注册，个人中心，设置模块
      // 主页模块
      // 未找到路由模块
      'pageIsNotFound': 'Page is not found',
      'pageIsNotFoundPleaseCheckIt': 'Page is not found, please check it',
      // 其他模块
      'textAndInput': 'Text And Input',
      'navigationBar': 'NavigationBar',
      'charConvert': 'Character Convert',
      'httpRequest': 'Http Request',
      'citySelected': 'City Selected',
      'listAndRefresh': 'List And Refresh',
      'dragList': 'Drag List',
      'videoPlay': 'Video Play',
      'notificationSwitch': 'Notification Switch',
      'verifyPhone': 'Verify Phone',
      'selectTheme': 'Select Theme',
      'selectLanguage': 'Select Language',
      'followSystem': 'Follow System',
      'loginRecord': 'Login Record',
      'checkUpgrade': 'Check Upgrade',
      'loadEmpty': 'Load Empty',
      'loadMore': 'Load More',
      'loadSuccess': 'Load Success',
      'loadComplete': 'Load Complete',
      'loadFailed': 'Load Failed',
      'loadEnd': 'Load To Bottom',
      'vlcVideoPlay': 'Vlc Video Play',
      'ijkVideoPlay': 'Ijk Video Play',
      // 通用文本
      'login': 'Login',
      'register': 'Register',
      'username': 'Username',
      'phone': 'Phone',
      'avatar': 'Avatar',
      'email': 'Email',
      'password': 'Password',
      'setting': 'Setting',
      'theme': 'Theme',
      'language': 'Language',
      'chinese': 'Chinese',
      'english': 'English',
      'logout': 'Logout',
      'exit': 'Exit',
      'home': 'Home',
      'me': 'Me',
      'state': 'State',
      'loading': 'Loading',
      'confirm': 'Confirm',
      'cancel': 'Cancel',
      'camera': 'Camera',
      'gallery': 'Gallery',
      'qr': 'QR',
      'navigation': 'Navigation',
      'walk': 'Walk',
      'keyword': 'Keyword',
      'unknown': 'Unknown',
      'none': '',
    },
  };

  Map<String, String> get _getLanguages => localizedValues[_locale.languageCode]!;

  String _getValues(String key) => _getLanguages[key] ?? _getLanguages['unknown']!;

  // 登录注册模块
  // 主页模块

  // 未找到路由模块
  String get pageIsNotFound => _getValues('pageIsNotFoundPleaseCheckIt');

  String get pageIsNotFoundPleaseCheckIt => _getValues('pageIsNotFoundPleaseCheckIt');

  // 其他模块
  String get textAndInput => _getValues('textAndInput');

  String get navigationBar => _getValues('navigationBar');

  String get charConvert => _getValues('charConvert');

  String get httpRequest => _getValues('httpRequest');

  String get citySelected => _getValues('citySelected');

  String get listAndRefresh => _getValues('listAndRefresh');

  String get dragList => _getValues('dragList');

  String get videoPlay => _getValues('videoPlay');

  String get notificationSwitch => _getValues('notificationSwitch');

  String get verifyPhone => _getValues('verifyPhone');

  String get selectTheme => _getValues('selectTheme');

  String get selectLanguage => _getValues('selectLanguage');

  String get followSystem => _getValues('followSystem');

  String get loginRecord => _getValues('loginRecord');

  String get checkUpgrade => _getValues('checkUpgrade');

  String get camera => _getValues('camera');

  String get gallery => _getValues('gallery');

  String get loadEmpty => _getValues('loadEmpty');

  String get loadMore => _getValues('loadMore');

  String get loadSuccess => _getValues('loadSuccess');

  String get loadComplete => _getValues('loadComplete');

  String get loadFailed => _getValues('loadFailed');

  String get loadEnd => _getValues('loadEnd');

  String get vlcVideoPlay => _getValues('vlcVideoPlay');

  String get ijkVideoPlay => _getValues('ijkVideoPlay');

  // 通用文本
  String get login => _getValues('login');

  String get register => _getValues('register');

  String get username => _getValues('username');

  String get password => _getValues('password');

  String get phone => _getValues('phone');

  String get avatar => _getValues('avatar');

  String get email => _getValues('email');

  String get setting => _getValues('setting');

  String get theme => _getValues('theme');

  String get language => _getValues('language');

  String get chinese => _getValues('chinese');

  String get english => _getValues('english');

  String get logout => _getValues('logout');

  String get exit => _getValues('exit');

  String get home => _getValues('home');

  String get me => _getValues('me');

  String get state => _getValues('state');

  String get loading => _getValues('loading');

  String get confirm => _getValues('confirm');

  String get cancel => _getValues('cancel');

  String get qr => _getValues('qr');

  String get navigation => _getValues('navigation');

  String get walk => _getValues('walk');

  String get keyword => _getValues('keyword');

  String get unknown => _getValues('unknown');

  String get none => _getValues('none');
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
