import '../app_page.dart';
import '../base/route/app_route_delegate.dart';
import 'common/example_page.dart';
import 'common/not_found_page.dart';
import 'common/web_view_page.dart';
import 'login/login_page.dart';
import 'login/register_page.dart';
import 'main/main_page.dart';
import 'main/me_page/me_router.dart';
import 'study/study_router.dart';

///
/// Created by a0010 on 2023/5/6 13:32
///
class Routers {
  static final String root = '/';
  static final String notFound = '/notFound';
  static final String login = '/login';
  static final String register = '/register';
  static final String main = '/main/';
  static final String example = '/example';
  static final String webView = '/webView';

  static List<AppRoutePage> get routers => [
        AppRoutePage(
          name: root,
          builder: (setting) {
            return AppPage();
          },
        ),
        AppRoutePage(
          name: notFound,
          builder: (setting) {
            return NotFoundPage();
          },
        ),
        AppRoutePage(
          name: login,
          builder: (setting) {
            return LoginPage();
          },
        ),
        AppRoutePage(
          name: register,
          builder: (setting) {
            return RegisterPage();
          },
        ),
        AppRoutePage(
          name: main,
          builder: (setting) {
            return MainPage();
          },
        ),
        AppRoutePage(
          name: example,
          builder: (setting) {
            return ExamplePage();
          },
        ),
        AppRoutePage(
          name: webView,
          builder: (setting) {
            dynamic args = setting.params;
            String title = args['title'] ?? '';
            String url = args['url'] ?? '';
            return WebViewPage(title: title, url: url);
          },
        ),
        ...MeRouter.routers,
        ...StudyRouter.routers,
      ];
}
