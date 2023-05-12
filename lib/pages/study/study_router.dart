import 'package:flutter_ui/pages/study/study_page.dart';

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
import 'qr_page/qr_page.dart';
import 'router/router_page.dart';
import 'state_page/state_page.dart';
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
    router.define(study, pagerBuilder: () {
      return StudyPage();
    });

    router.define(city, pagerBuilder: () {
      return CitySelectedPage();
    });

    router.define(convert, pagerBuilder: () {
      return ConvertPage();
    });

    router.define(dragList, pagerBuilder: () {
      return DragListPage();
    });

    router.define(floatNavigation, pagerBuilder: () {
      return FloatNavigationPage();
    });

    router.define(http, pagerBuilder: () {
      return HTTPListPage();
    });

    router.define(image, pagerBuilder: () {
      return ImageEditorPage();
    });

    router.define(keyword, pagerBuilder: () {
      return KeywordBoardPage();
    });

    router.define(list, pagerBuilder: () {
      return ListPage();
    });

    router.define(loadImage, pagerBuilder: () {
      return LoadImagePage();
    });

    router.define(qr, pagerBuilder: () {
      return QRPage();
    });

    router.define(routers, pagerBuilder: () {
      return RouterPage();
    });

    router.define(state, pagerBuilder: () {
      return StatePage();
    });

    router.define(text, pagerBuilder: () {
      return TextPage();
    });

    router.define(video, pagerBuilder: () {
      return VideoPage();
    });
  }
}
