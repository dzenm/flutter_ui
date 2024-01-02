import '../app_page.dart';
import '../base/base.dart';
import 'common/example_page.dart';
import 'common/not_found_page.dart';
import 'common/preview_picture_page.dart';
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
  static const String notFound = '/notFound';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String example = '/example';
  static const String webView = '/webView';
  static const String preview = '/preview';

  static List<AppPageConfig> get routers => [
        AppPageConfig(
          name: root,
          builder: (settings) {
            return const AppPage();
          },
        ),
        AppPageConfig(
          name: notFound,
          builder: (settings) {
            return const NotFoundPage();
          },
        ),
        AppPageConfig(
          name: login,
          builder: (settings) {
            return LoginPage();
          },
        ),
        AppPageConfig(
          name: register,
          builder: (settings) {
            return const RegisterPage();
          },
        ),
        AppPageConfig(
          name: main,
          builder: (settings) {
            return const MainPage();
          },
        ),
        AppPageConfig(
          name: example,
          builder: (settings) {
            return const ExamplePage();
          },
        ),
        AppPageConfig(
          name: webView,
          builder: (settings) {
            dynamic args = settings.queries;
            String title = args['title'] ?? '';
            String url = args['url'] ?? '';
            return WebViewPage(title: title, url: url);
          },
        ),
        AppPageConfig(
          name: preview,
          builder: (settings) {
            // dynamic args = settings.params;
            // String title = args['title'] ?? '';
            // String url = args['url'] ?? '';
            return const PreviewPicturePage([]);
          },
        ),
        ...MeRouter.routers,
        ...StudyRouter.routers,
        ...MallRouter.routers,
      ];
}
