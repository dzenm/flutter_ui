import '../../base/route/app_route_delegate.dart';
import 'city_page/city_page.dart';
import 'convert_page/convert_page.dart';
import 'dialog_page/dialog_page.dart';
import 'drag_list_page/drag_list_page.dart';
import 'float_navigation_page/float_navigation_page.dart';
import 'http_page/http_page.dart';
import 'image_editor/image_editor_page.dart';
import 'keyword_board/keyword_board_page.dart';
import 'list_page/list_page.dart';
import 'load_image_page/load_image_page.dart';
import 'popup_page/popup_page.dart';
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
class StudyRouter {
  static final String study = '/study';
  static final String city = '$study/city';
  static final String convert = '$study/convert';
  static final String dialog = '$study/dialog';
  static final String dragList = '$study/dragList';
  static final String floatNavigation = '$study/floatNavigation';
  static final String http = '$study/http';
  static final String image = '$study/image';
  static final String keyword = '$study/keyword';
  static final String list = '$study/list';
  static final String loadImage = '$study/loadImage';
  static final String popup = '$study/popup';
  static final String provider = '$study/provider';
  static final String qr = '$study/qr';
  static final String router = '$study/router';
  static final String state = '$study/state';
  static final String text = '$study/text';
  static final String video = '$study/video';

  static List<AppRoutePage> get routers => [
        AppRoutePage(
          name: study,
          builder: (params) {
            return StudyPage();
          },
        ),
        AppRoutePage(
          name: city,
          builder: (params) {
            return CitySelectedPage();
          },
        ),
        AppRoutePage(
          name: convert,
          builder: (params) {
            return ConvertPage();
          },
        ),
        AppRoutePage(
          name: dialog,
          builder: (params) {
            return DialogPage();
          },
        ),
        AppRoutePage(
          name: dragList,
          builder: (params) {
            return DragListPage();
          },
        ),
        AppRoutePage(
          name: floatNavigation,
          builder: (params) {
            return FloatNavigationPage();
          },
        ),
        AppRoutePage(
          name: http,
          builder: (params) {
            return HTTPListPage();
          },
        ),
        AppRoutePage(
          name: image,
          builder: (params) {
            return ImageEditorPage();
          },
        ),
        AppRoutePage(
          name: keyword,
          builder: (params) {
            return KeywordBoardPage();
          },
        ),
        AppRoutePage(
          name: list,
          builder: (params) {
            return ListPage();
          },
        ),
        AppRoutePage(
          name: loadImage,
          builder: (params) {
            return LoadImagePage();
          },
        ),
        AppRoutePage(
          name: popup,
          builder: (params) {
            return PopupPage();
          },
        ),
        AppRoutePage(
          name: provider,
          builder: (params) {
            return ProviderPage();
          },
        ),
        AppRoutePage(
          name: qr,
          builder: (params) {
            return QRPage();
          },
        ),
        AppRoutePage(
          name: router,
          builder: (params) {
            return RouterPage();
          },
        ),
        AppRoutePage(
          name: state,
          builder: (params) {
            return StatePage();
          },
        ),
        AppRoutePage(
          name: text,
          builder: (params) {
            return TextPage();
          },
        ),
        AppRoutePage(
          name: video,
          builder: (params) {
            return VideoPage();
          },
        ),
      ];
}
