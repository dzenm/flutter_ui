import '../app_page.dart';
import '../base/base.dart';
import 'common/example_page.dart';
import 'common/not_found_page.dart';
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
  static const String root = '/';
  static const String notFound = '${root}notFound';
  static const String login = '${root}login';
  static const String register = '${root}register';
  static const String main = '${root}main';
  static const String example = '${root}example';
  static const String webView = '${root}webView';
  static const String viewMedia = '${root}viewMedia';

  static List<AppPageConfig> get routers => [
        AppPageConfig(notFound, builder: (settings) {
          return const NotFoundPage();
        }),
        AppPageConfig(login, builder: (settings) {
          return LoginPage();
        }),
        AppPageConfig(register, builder: (settings) {
          return const RegisterPage();
        }),
        AppPageConfig(main, builder: (settings) {
          return const MainPage();
        }),
        AppPageConfig(example, builder: (settings) {
          return const ExamplePage();
        }),
        AppPageConfig(webView, builder: (settings) {
          dynamic args = settings.queryParameters;
          String title = args['title'] ?? '';
          String url = args['url'] ?? '';
          return WebViewPage(title: title, url: url);
        }),
        AppPageConfig(viewMedia, builder: (settings) {
          // dynamic args = settings.queryParameters;
          // String title = args['title'] ?? '';
          // String url = args['url'] ?? '';
          return const ViewMediaPage(medias: []);
        }),
        ...MeRouter.routers,
        ...StudyRouter.routers,
        ...MallRouter.routers,
      ];
}
