import '../../base/base.dart';
import 'chat/chat_page.dart';
import 'city/city_page.dart';
import 'convert/convert_page.dart';
import 'desktop/desktop_page.dart';
import 'desktop/screen_capture_page.dart';
import 'dialog/dialog_page.dart';
import 'drag/drag_list_page.dart';
import 'float_navigation/float_navigation_page.dart';
import 'http/http_page.dart';
import 'image/image_editor_page.dart';
import 'keyword/keyword_board_page.dart';
import 'list/list_page.dart';
import 'load_image/load_image_page.dart';
import 'popup/popup_page.dart';
import 'provider/provider_page.dart';
import 'qr/qr_page.dart';
import 'router/router_page.dart';
import 'slider/slide_page.dart';
import 'state/state_page.dart';
import 'study_page.dart';
import 'text/text_page.dart';
import 'video/video_page.dart';
import 'window/main_window_page.dart';

///
/// Created by a0010 on 2023/5/11 16:05
///
class StudyRouter {
  static const String study = '/study';
  static const String chat = '$study/chat';
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
  static const String multiWindow = '$study/multiWindow';
  static const String desktop = '$study/desktop';
  static const String screenCapture = '$study/screenCapture';

  static List<AppPageConfig> get routers => [
        AppPageConfig(study, builder: (settings) {
          return const StudyPage();
        }),
        AppPageConfig(chat, builder: (settings) {
          return const ChatPage();
        }),
        AppPageConfig(city, builder: (settings) {
          return const CitySelectedPage();
        }),
        AppPageConfig(convert, builder: (settings) {
          return const ConvertPage();
        }),
        AppPageConfig(dialog, builder: (settings) {
          return const DialogPage();
        }),
        AppPageConfig(dragList, builder: (settings) {
          return const DragListPage();
        }),
        AppPageConfig(floatNavigation, builder: (settings) {
          return const FloatNavigationPage();
        }),
        AppPageConfig(http, builder: (settings) {
          return const HTTPListPage();
        }),
        AppPageConfig(image, builder: (settings) {
          return const ImageEditorPage();
        }),
        AppPageConfig(keyword, builder: (settings) {
          return const KeywordBoardPage();
        }),
        AppPageConfig(list, builder: (settings) {
          return const ListPage();
        }),
        AppPageConfig(loadImage, builder: (settings) {
          return const LoadImagePage();
        }),
        AppPageConfig(popup, builder: (settings) {
          return const PopupPage();
        }),
        AppPageConfig(provider, builder: (settings) {
          return const ProviderPage();
        }),
        AppPageConfig(qr, builder: (settings) {
          return const QRPage();
        }),
        AppPageConfig(router, builder: (settings) {
          return const RouterPage();
        }),
        AppPageConfig(slide, builder: (settings) {
          return const SlidePage();
        }),
        AppPageConfig(state, builder: (settings) {
          return const StatePage();
        }),
        AppPageConfig(text, builder: (settings) {
          return const TextPage();
        }),
        AppPageConfig(video, builder: (settings) {
          return const VideoPage();
        }),
        AppPageConfig(multiWindow, builder: (settings) {
          return const MainWindowPage();
        }),
        AppPageConfig(desktop, builder: (settings) {
          return const DesktopPage();
        }),
        AppPageConfig(screenCapture, builder: (settings) {
          return const ScreenCapturePage();
        }),
      ];
}
