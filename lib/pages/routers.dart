import 'package:flutter/material.dart';

import '../base/route/app_router.dart';
import 'common/example_page.dart';
import 'common/web_view_page.dart';
import 'login/login_page.dart';
import 'login/register_page.dart';
import 'main/main_page.dart';
import 'main/me_page/me_router.dart';
import 'study/study_router.dart';

///
/// Created by a0010 on 2023/5/6 13:32
///
class Routers extends IRouter {
  static List<IRouter> _routers = [];

  static void init() {
    _routers.add(Routers());
    _routers.add(StudyRouter());
    _routers.add(MeRouter());

    for (var router in _routers) {
      router.initRouter(AppRouter());
    }
  }

  static final String root = '/';
  static final String login = '/login';
  static final String register = '/register';
  static final String main = '/main';
  static final String example = '/example';
  static final String webView = '/webView';

  static final StudyRouter studyRouter = StudyRouter();
  static final MeRouter meRouter = MeRouter();

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
    router.define(webView, pagerBuilder: (context) {
      dynamic args = ModalRoute.of(context)?.settings.arguments;
      String title = args['title'] ?? '';
      String url = args['url'] ?? '';
      return WebViewPage(title: title, url: url);
    });
  }
}
