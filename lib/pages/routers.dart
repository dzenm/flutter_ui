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
  static final String main = '/main';
  static final String example = '/example';
  static final String webView = '/webView';

  static List<AppRoutePage> get routers => [
        AppRoutePage(
          name: root,
          builder: (params) {
            return AppPage();
          },
        ),
        AppRoutePage(
          name: notFound,
          builder: (params) {
            return NotFoundPage();
          },
        ),
        AppRoutePage(
          name: login,
          builder: (params) {
            return LoginPage();
          },
        ),
        AppRoutePage(
          name: register,
          builder: (params) {
            return RegisterPage();
          },
        ),
        AppRoutePage(
          name: main,
          builder: (params) {
            return MainPage();
          },
        ),
        AppRoutePage(
          name: example,
          builder: (params) {
            return ExamplePage();
          },
        ),
        AppRoutePage(
          name: webView,
          builder: (params) {
            dynamic args = params;
            String title = args['title'] ?? '';
            String url = args['url'] ?? '';
            return WebViewPage(title: title, url: url);
          },
        ),
      ]
        ..addAll(MeRouter.routers)
        ..addAll(StudyRouter.routers);
}
