import '../app_page.dart';
import '../base/route/app_route_delegate.dart';
import 'common/example_page.dart';
import 'common/not_found_page.dart';
import 'common/web_view_page.dart';
import 'login/login_page.dart';
import 'login/register_page.dart';
import 'main/main_page.dart';
import 'main/me/me_router.dart';
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

  static List<AppRoutePage> get routers => [
        AppRoutePage(
          name: root,
          builder: (settings) {
            return const AppPage();
          },
        ),
        AppRoutePage(
          name: notFound,
          builder: (settings) {
            return const NotFoundPage();
          },
        ),
        AppRoutePage(
          name: login,
          builder: (settings) {
            return const LoginPage();
          },
        ),
        AppRoutePage(
          name: register,
          builder: (settings) {
            return const RegisterPage();
          },
        ),
        AppRoutePage(
          name: main,
          builder: (settings) {
            return const MainPage();
          },
        ),
        AppRoutePage(
          name: example,
          builder: (settings) {
            return const ExamplePage();
          },
        ),
        AppRoutePage(
          name: webView,
          builder: (settings) {
            dynamic args = settings.params;
            String title = args['title'] ?? '';
            String url = args['url'] ?? '';
            return WebViewPage(title: title, url: url);
          },
        ),
        ...MeRouter.routers,
        ...StudyRouter.routers,
      ];
}
