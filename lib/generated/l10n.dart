// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name =
        (locale.countryCode?.isEmpty ?? false)
            ? locale.languageCode
            : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Flutter UI`
  String get appName {
    return Intl.message('Flutter UI', name: 'appName', desc: '', args: []);
  }

  /// `Login`
  String get login {
    return Intl.message('Login', name: 'login', desc: '', args: []);
  }

  /// `Verify Code`
  String get verifyCode {
    return Intl.message('Verify Code', name: 'verifyCode', desc: '', args: []);
  }

  /// `Send`
  String get send {
    return Intl.message('Send', name: 'send', desc: '', args: []);
  }

  /// `s`
  String get second {
    return Intl.message('s', name: 'second', desc: '', args: []);
  }

  /// `Register`
  String get register {
    return Intl.message('Register', name: 'register', desc: '', args: []);
  }

  /// `Logout`
  String get logout {
    return Intl.message('Logout', name: 'logout', desc: '', args: []);
  }

  /// `Avatar`
  String get avatar {
    return Intl.message('Avatar', name: 'avatar', desc: '', args: []);
  }

  /// `Username`
  String get username {
    return Intl.message('Username', name: 'username', desc: '', args: []);
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Repeat Password`
  String get rPassword {
    return Intl.message(
      'Repeat Password',
      name: 'rPassword',
      desc: '',
      args: [],
    );
  }

  /// `ID`
  String get id {
    return Intl.message('ID', name: 'id', desc: '', args: []);
  }

  /// `Phone`
  String get phone {
    return Intl.message('Phone', name: 'phone', desc: '', args: []);
  }

  /// `Email`
  String get email {
    return Intl.message('Email', name: 'email', desc: '', args: []);
  }

  /// `Keyword`
  String get keyword {
    return Intl.message('Keyword', name: 'keyword', desc: '', args: []);
  }

  /// `Collect`
  String get collect {
    return Intl.message('Collect', name: 'collect', desc: '', args: []);
  }

  /// `Coin`
  String get coin {
    return Intl.message('Coin', name: 'coin', desc: '', args: []);
  }

  /// `Setting`
  String get setting {
    return Intl.message('Setting', name: 'setting', desc: '', args: []);
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Theme`
  String get theme {
    return Intl.message('Theme', name: 'theme', desc: '', args: []);
  }

  /// `Language`
  String get language {
    return Intl.message('Language', name: 'language', desc: '', args: []);
  }

  /// `Chinese`
  String get chinese {
    return Intl.message('Chinese', name: 'chinese', desc: '', args: []);
  }

  /// `English`
  String get english {
    return Intl.message('English', name: 'english', desc: '', args: []);
  }

  /// `About`
  String get about {
    return Intl.message('About', name: 'about', desc: '', args: []);
  }

  /// `Exit`
  String get exit {
    return Intl.message('Exit', name: 'exit', desc: '', args: []);
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Nav`
  String get nav {
    return Intl.message('Nav', name: 'nav', desc: '', args: []);
  }

  /// `Me`
  String get me {
    return Intl.message('Me', name: 'me', desc: '', args: []);
  }

  /// `State`
  String get state {
    return Intl.message('State', name: 'state', desc: '', args: []);
  }

  /// `Loading`
  String get loading {
    return Intl.message('Loading', name: 'loading', desc: '', args: []);
  }

  /// `Load Empty`
  String get loadEmpty {
    return Intl.message('Load Empty', name: 'loadEmpty', desc: '', args: []);
  }

  /// `Load More`
  String get loadMore {
    return Intl.message('Load More', name: 'loadMore', desc: '', args: []);
  }

  /// `Keep Sliding`
  String get keepSliding {
    return Intl.message(
      'Keep Sliding',
      name: 'keepSliding',
      desc: '',
      args: [],
    );
  }

  /// `Load Success`
  String get loadSuccess {
    return Intl.message(
      'Load Success',
      name: 'loadSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Load Complete`
  String get loadComplete {
    return Intl.message(
      'Load Complete',
      name: 'loadComplete',
      desc: '',
      args: [],
    );
  }

  /// `Load Failed`
  String get loadFailed {
    return Intl.message('Load Failed', name: 'loadFailed', desc: '', args: []);
  }

  /// `Load End`
  String get loadEnd {
    return Intl.message('Load End', name: 'loadEnd', desc: '', args: []);
  }

  /// `Release Finger`
  String get releaseFinger {
    return Intl.message(
      'Release Finger',
      name: 'releaseFinger',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Camera`
  String get camera {
    return Intl.message('Camera', name: 'camera', desc: '', args: []);
  }

  /// `Gallery`
  String get gallery {
    return Intl.message('Gallery', name: 'gallery', desc: '', args: []);
  }

  /// `Router`
  String get router {
    return Intl.message('Router', name: 'router', desc: '', args: []);
  }

  /// `Unknown`
  String get unknown {
    return Intl.message('Unknown', name: 'unknown', desc: '', args: []);
  }

  /// ``
  String get none {
    return Intl.message('', name: 'none', desc: '', args: []);
  }

  /// `QR`
  String get qr {
    return Intl.message('QR', name: 'qr', desc: '', args: []);
  }

  /// `Test`
  String get test {
    return Intl.message('Test', name: 'test', desc: '', args: []);
  }

  /// `My Profile`
  String get profile {
    return Intl.message('My Profile', name: 'profile', desc: '', args: []);
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: '',
      args: [],
    );
  }

  /// `Plaza`
  String get plaza {
    return Intl.message('Plaza', name: 'plaza', desc: '', args: []);
  }

  /// `Tutorial`
  String get tutorial {
    return Intl.message('Tutorial', name: 'tutorial', desc: '', args: []);
  }

  /// `Q&A`
  String get qa {
    return Intl.message('Q&A', name: 'qa', desc: '', args: []);
  }

  /// `Project`
  String get project {
    return Intl.message('Project', name: 'project', desc: '', args: []);
  }

  /// `Official`
  String get official {
    return Intl.message('Official', name: 'official', desc: '', args: []);
  }

  /// `Tool`
  String get tool {
    return Intl.message('Tool', name: 'tool', desc: '', args: []);
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Read And Agree`
  String get readAndAgree {
    return Intl.message(
      'Read And Agree',
      name: 'readAndAgree',
      desc: '',
      args: [],
    );
  }

  /// `<Register Protocol>`
  String get registerProtocol {
    return Intl.message(
      '<Register Protocol>',
      name: 'registerProtocol',
      desc: '',
      args: [],
    );
  }

  /// `<Private Protocol>`
  String get privateProtocol {
    return Intl.message(
      '<Private Protocol>',
      name: 'privateProtocol',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Platform`
  String get unknownPlatform {
    return Intl.message(
      'Unknown Platform',
      name: 'unknownPlatform',
      desc: '',
      args: [],
    );
  }

  /// `Page is not found`
  String get notFoundPage {
    return Intl.message(
      'Page is not found',
      name: 'notFoundPage',
      desc: '',
      args: [],
    );
  }

  /// `Check Upgrade`
  String get checkUpgrade {
    return Intl.message(
      'Check Upgrade',
      name: 'checkUpgrade',
      desc: '',
      args: [],
    );
  }

  /// `Select Theme`
  String get selectTheme {
    return Intl.message(
      'Select Theme',
      name: 'selectTheme',
      desc: '',
      args: [],
    );
  }

  /// `Select Language`
  String get selectLanguage {
    return Intl.message(
      'Select Language',
      name: 'selectLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Follow System`
  String get followSystem {
    return Intl.message(
      'Follow System',
      name: 'followSystem',
      desc: '',
      args: [],
    );
  }

  /// `Exit Logout`
  String get exitLogout {
    return Intl.message('Exit Logout', name: 'exitLogout', desc: '', args: []);
  }

  /// `About Our`
  String get aboutMe {
    return Intl.message('About Our', name: 'aboutMe', desc: '', args: []);
  }

  /// `Chinese Medicine`
  String get chineseMedicine {
    return Intl.message(
      'Chinese Medicine',
      name: 'chineseMedicine',
      desc: '',
      args: [],
    );
  }

  /// `Integral Ranking List`
  String get integralRankingList {
    return Intl.message(
      'Integral Ranking List',
      name: 'integralRankingList',
      desc: '',
      args: [],
    );
  }

  /// `Shared Article`
  String get sharedArticle {
    return Intl.message(
      'Shared Article',
      name: 'sharedArticle',
      desc: '',
      args: [],
    );
  }

  /// `Login Record`
  String get loginRecord {
    return Intl.message(
      'Login Record',
      name: 'loginRecord',
      desc: '',
      args: [],
    );
  }

  /// `Coin Record`
  String get coinRecord {
    return Intl.message('Coin Record', name: 'coinRecord', desc: '', args: []);
  }

  /// `Study MainPage{name}`
  String studyMainPage(Object name) {
    return Intl.message(
      'Study MainPage$name',
      name: 'studyMainPage',
      desc: '',
      args: [name],
    );
  }

  /// `Successfully Modified`
  String get successfullyModified {
    return Intl.message(
      'Successfully Modified',
      name: 'successfullyModified',
      desc: '',
      args: [],
    );
  }

  /// `Already The Latest Version`
  String get alreadyTheLatestVersion {
    return Intl.message(
      'Already The Latest Version',
      name: 'alreadyTheLatestVersion',
      desc: '',
      args: [],
    );
  }

  /// `Mall`
  String get mall {
    return Intl.message('Mall', name: 'mall', desc: '', args: []);
  }

  /// `Contact`
  String get contact {
    return Intl.message('Contact', name: 'contact', desc: '', args: []);
  }

  /// `Recipient Name`
  String get recipientName {
    return Intl.message(
      'Recipient Name',
      name: 'recipientName',
      desc: '',
      args: [],
    );
  }

  /// `Shipping Address`
  String get shippingAddress {
    return Intl.message(
      'Shipping Address',
      name: 'shippingAddress',
      desc: '',
      args: [],
    );
  }

  /// `Recipient's Detailed Address`
  String get recipientsDetailedAddress {
    return Intl.message(
      'Recipient\'s Detailed Address',
      name: 'recipientsDetailedAddress',
      desc: '',
      args: [],
    );
  }

  /// `Recipient Contact Info`
  String get recipientContactInfo {
    return Intl.message(
      'Recipient Contact Info',
      name: 'recipientContactInfo',
      desc: '',
      args: [],
    );
  }

  /// `Tracking Number`
  String get trackingNumber {
    return Intl.message(
      'Tracking Number',
      name: 'trackingNumber',
      desc: '',
      args: [],
    );
  }

  /// `Order`
  String get order {
    return Intl.message('Order', name: 'order', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
