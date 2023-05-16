import 'package:flutter_ui/pages/common/example_page.dart';
import 'package:flutter_ui/pages/main/me_page/article/article_page.dart';
import 'package:flutter_ui/pages/main/me_page/coin/coin_page.dart';
import 'package:flutter_ui/pages/main/me_page/collect/collect_page.dart';
import 'package:flutter_ui/pages/main/me_page/edit_info_page.dart';
import 'package:flutter_ui/pages/main/me_page/medicine/medicine_page.dart';
import 'package:flutter_ui/pages/main/me_page/rank/rank_page.dart';
import 'package:flutter_ui/pages/main/me_page/view_info_page.dart';

import '../base/route/app_router.dart';
import 'login/login_page.dart';
import 'login/register_page.dart';
import 'main/main_page.dart';
import 'main/me_page/setting_page/setting_page.dart';
import 'study/study_router.dart';

///
/// Created by a0010 on 2023/5/6 13:32
///
class Routers extends IRouter {
  static List<IRouter> _routers = [];

  static void init() {
    _routers.add(Routers());
    _routers.add(StudyRouter());

    for (var router in _routers) {
      router.initRouter(AppRouter());
    }
  }

  static final String root = '/';
  static final String login = '/login';
  static final String register = '/register';
  static final String main = '/main';
  static final String example = '/example';

  static final String article = '/me/article';
  static final String coin = '/me/coin';
  static final String collect = '/me/collect';
  static final String medicine = '/me/medicine';
  static final String rank = '/me/rank';
  static final String setting = '/me/setting';
  static final String editInfo = '/me/editInfo';
  static final String viewInfo = '/me/viewInfo';

  static final StudyRouter study = StudyRouter();

  @override
  void initRouter(AppRouter router) {
    router.define(login, pagerBuilder: (context) {
      return LoginPage();
    });
    router.define(register, pagerBuilder: (context) {
      return RegisterPage();
    });
    router.define(main, pagerBuilder: (context) {
      return MainPage();
    });
    router.define(example, pagerBuilder: (context) {
      return ExamplePage();
    });
    router.define(article, pagerBuilder: (context) {
      return ArticlePage();
    });
    router.define(coin, pagerBuilder: (context) {
      return CoinPage();
    });
    router.define(collect, pagerBuilder: (context) {
      return CollectPage();
    });
    router.define(medicine, pagerBuilder: (context) {
      return MedicinePage(medicineName: '');
    });
    router.define(rank, pagerBuilder: (context) {
      return RankPage();
    });
    router.define(setting, pagerBuilder: (context) {
      return SettingPage();
    });
    router.define(editInfo, pagerBuilder: (context) {
      return EditInfoPage();
    });
    router.define(viewInfo, pagerBuilder: (context) {
      return ViewInfoPage();
    });
  }
}
