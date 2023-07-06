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
          builder: (setting) {
            return StudyPage();
          },
        ),
        AppRoutePage(
          name: city,
          builder: (setting) {
            return CitySelectedPage();
          },
        ),
        AppRoutePage(
          name: convert,
          builder: (setting) {
            return ConvertPage();
          },
        ),
        AppRoutePage(
          name: dialog,
          builder: (setting) {
            return DialogPage();
          },
        ),
        AppRoutePage(
          name: dragList,
          builder: (setting) {
            return DragListPage();
          },
        ),
        AppRoutePage(
          name: floatNavigation,
          builder: (setting) {
            return FloatNavigationPage();
          },
        ),
        AppRoutePage(
          name: http,
          builder: (setting) {
            return HTTPListPage();
          },
        ),
        AppRoutePage(
          name: image,
          builder: (setting) {
            return ImageEditorPage();
          },
        ),
        AppRoutePage(
          name: keyword,
          builder: (setting) {
            return KeywordBoardPage();
          },
        ),
        AppRoutePage(
          name: list,
          builder: (setting) {
            return ListPage();
          },
        ),
        AppRoutePage(
          name: loadImage,
          builder: (setting) {
            return LoadImagePage();
          },
        ),
        AppRoutePage(
          name: popup,
          builder: (setting) {
            return PopupPage();
          },
        ),
        AppRoutePage(
          name: provider,
          builder: (setting) {
            return ProviderPage();
          },
        ),
        AppRoutePage(
          name: qr,
          builder: (setting) {
            return QRPage();
          },
        ),
        AppRoutePage(
          name: router,
          builder: (setting) {
            return RouterPage();
          },
        ),
        AppRoutePage(
          name: state,
          builder: (setting) {
            return StatePage();
          },
        ),
        AppRoutePage(
          name: text,
          builder: (setting) {
            return TextPage();
          },
        ),
        AppRoutePage(
          name: video,
          builder: (setting) {
            return VideoPage();
          },
        ),
      ];
}
