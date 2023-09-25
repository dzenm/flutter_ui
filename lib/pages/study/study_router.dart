import '../../base/base.dart';
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
import 'slider_page/slide_page.dart';
import 'state_page/state_page.dart';
import 'study_page.dart';
import 'text_page/text_page.dart';
import 'video_page/video_page.dart';

///
/// Created by a0010 on 2023/5/11 16:05
///
class StudyRouter {
  static const String study = '/study';
  static const String city = '$study/city';
  static const String convert = '$study/convert';
  static const String dialog = '$study/dialog';
  static const String dragList = '$study/dragList';
  static const String floatNavigation = '$study/floatNavigation';
  static const String http = '$study/http';
  static const String image = '$study/image';
  static const String keyword = '$study/keyword';
  static const String list = '$study/list';
  static const String loadImage = '$study/loadImage';
  static const String popup = '$study/popup';
  static const String provider = '$study/provider';
  static const String qr = '$study/qr';
  static const String router = '$study/router';
  static const String slide = '$study/slide';
  static const String state = '$study/state';
  static const String text = '$study/text';
  static const String video = '$study/video';

  static List<AppRoutePage> get routers => [
        AppRoutePage(
          name: study,
          builder: (settings) {
            return const StudyPage();
          },
        ),
        AppRoutePage(
          name: city,
          builder: (settings) {
            return const CitySelectedPage();
          },
        ),
        AppRoutePage(
          name: convert,
          builder: (settings) {
            return const ConvertPage();
          },
        ),
        AppRoutePage(
          name: dialog,
          builder: (settings) {
            return const DialogPage();
          },
        ),
        AppRoutePage(
          name: dragList,
          builder: (settings) {
            return const DragListPage();
          },
        ),
        AppRoutePage(
          name: floatNavigation,
          builder: (settings) {
            return const FloatNavigationPage();
          },
        ),
        AppRoutePage(
          name: http,
          builder: (settings) {
            return const HTTPListPage();
          },
        ),
        AppRoutePage(
          name: image,
          builder: (settings) {
            return const ImageEditorPage();
          },
        ),
        AppRoutePage(
          name: keyword,
          builder: (settings) {
            return const KeywordBoardPage();
          },
        ),
        AppRoutePage(
          name: list,
          builder: (settings) {
            return const ListPage();
          },
        ),
        AppRoutePage(
          name: loadImage,
          builder: (settings) {
            return const LoadImagePage();
          },
        ),
        AppRoutePage(
          name: popup,
          builder: (settings) {
            return const PopupPage();
          },
        ),
        AppRoutePage(
          name: provider,
          builder: (settings) {
            return const ProviderPage();
          },
        ),
        AppRoutePage(
          name: qr,
          builder: (settings) {
            return const QRPage();
          },
        ),
        AppRoutePage(
          name: router,
          builder: (settings) {
            return const RouterPage();
          },
        ),
        AppRoutePage(
          name: slide,
          builder: (settings) {
            return const SlidePage();
          },
        ),
        AppRoutePage(
          name: state,
          builder: (settings) {
            return const StatePage();
          },
        ),
        AppRoutePage(
          name: text,
          builder: (settings) {
            return const TextPage();
          },
        ),
        AppRoutePage(
          name: video,
          builder: (settings) {
            return const VideoPage();
          },
        ),
      ];
}
