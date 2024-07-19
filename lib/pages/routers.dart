import 'package:bot_toast/bot_toast.dart';

import '../base/a_router/route.dart';
import '../base/a_router/router.dart';
import '../base/base.dart';
import 'common/example_page.dart';
import 'common/view_media_page.dart';
import 'common/web_view_page.dart';
import 'login/login_page.dart';
import 'login/register_page.dart';
import 'main/main_page.dart';
import 'main/me/me_router.dart';
import 'mall/mall_router.dart';
import 'study/study_router.dart';

///
/// Created by a0010 on 2023/5/6 13:32
///
class Routers {
  static const String login = 'login';
  static const String register = 'register';
  static const String main = 'main';
  static const String home = 'home';
  static const String nav = 'nav';
  static const String me = 'me';
  static const String example = 'example';
  static const String webView = 'webView';
  static const String viewMedia = 'viewMedia';

  static final routes = ARouter(
    observers: [
      BotToastNavigatorObserver(),
    ],
    log: Log.d,
    initialLocation: SPManager.getUserLoginState() ? '/main' : '/login',
    routes: [
      ARoute(
        name: login,
        path: '/login',
        builder: (context, state) => LoginPage(),
      ),
      ARoute(
        name: register,
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      ARoute(
        name: main,
        path: '/main',
        builder: (context, state) => const MainPage(),
        routes: [
          ARoute(
            name: example,
            path: 'example',
            builder: (context, state) => const ExamplePage(),
          ),
          ARoute(
            name: webView,
            path: 'webView',
            builder: (context, state) {
              dynamic args = state.uri.queryParameters;
              String title = args['title'] ?? '';
              String url = args['url'] ?? '';
              return WebViewPage(title: title, url: url);
            },
          ),
          ARoute(
            name: viewMedia,
            path: 'viewMedia',
            builder: (context, state) {
              // dynamic args = settings.queryParameters;
              // String title = args['title'] ?? '';
              // String url = args['url'] ?? '';
              return const ViewMediaPage(medias: []);
            },
          ),
          ...MeRouter.routers,
          ...StudyRouter.routers,
          ...MallRouter.routers,
        ],
      ),
    ],
  );
}
