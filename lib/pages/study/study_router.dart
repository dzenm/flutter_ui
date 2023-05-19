
import '../../base/route/app_router.dart';
import 'city_page/city_page.dart';
import 'convert_page/convert_page.dart';
import 'drag_list_page/drag_list_page.dart';
import 'float_navigation_page/float_navigation_page.dart';
import 'http_page/http_page.dart';
import 'image_editor/image_editor_page.dart';
import 'keyword_board/keyword_board_page.dart';
import 'list_page/list_page.dart';
import 'load_image_page/load_image_page.dart';
import 'provider_page/provider_page.dart';
import 'qr_page/qr_page.dart';
import 'router/router_page.dart';
import 'state_page/state_page.dart';
import 'study_page.dart';
import 'text_page/text_page.dart';
import 'video_page/video_page.dart';

///
/// Created by a0010 on 2023/5/11 16:05
///
class StudyRouter extends IRouter {
  String study = '/study';
  String city = '/study/city';
  String convert = '/study/convert';
  String dragList = '/study/dragList';
  String floatNavigation = '/study/floatNavigation';
  String http = '/study/http';
  String image = '/study/image';
  String keyword = '/study/keyword';
  String list = '/study/list';
  String loadImage = '/study/loadImage';
  String provider = '/study/provider';
  String qr = '/study/qr';
  String routers = '/study/routers';
  String state = '/study/state';
  String text = '/study/text';
  String video = '/study/video';

  @override
  void initRouter(AppRouter router) {
    router.define(study, pagerBuilder: (context) {
      return StudyPage();
    });

    router.define(city, pagerBuilder: (context) {
      return CitySelectedPage();
    });

    router.define(convert, pagerBuilder: (context) {
      return ConvertPage();
    });

    router.define(dragList, pagerBuilder: (context) {
      return DragListPage();
    });

    router.define(floatNavigation, pagerBuilder: (context) {
      return FloatNavigationPage();
    });

    router.define(http, pagerBuilder: (context) {
      return HTTPListPage();
    });

    router.define(image, pagerBuilder: (context) {
      return ImageEditorPage();
    });

    router.define(keyword, pagerBuilder: (context) {
      return KeywordBoardPage();
    });

    router.define(list, pagerBuilder: (context) {
      return ListPage();
    });

    router.define(loadImage, pagerBuilder: (context) {
      return LoadImagePage();
    });

    router.define(provider, pagerBuilder: (context) {
      return ProviderPage();
    });

    router.define(qr, pagerBuilder: (context) {
      return QRPage();
    });

    router.define(routers, pagerBuilder: (context) {
      return RouterPage();
    });

    router.define(state, pagerBuilder: (context) {
      return StatePage();
    });

    router.define(text, pagerBuilder: (context) {
      return TextPage();
    });

    router.define(video, pagerBuilder: (context) {
      return VideoPage();
    });
  }
}
