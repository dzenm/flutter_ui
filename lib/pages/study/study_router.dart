import '../../base/base.dart';
import 'components/chat/chat_page.dart';
import 'components/city/city_page.dart';
import 'components/components_page.dart';
import 'components/dialog/dialog_page.dart';
import 'components/drag/drag_list_page.dart';
import 'components/float_navigation/float_navigation_page.dart';
import 'components/image/image_editor_page.dart';
import 'components/keyword/keyword_board_page.dart';
import 'components/list/list_page.dart';
import 'components/popup/popup_page.dart';
import 'components/qr/qr_page.dart';
import 'components/recording/recording_page.dart';
import 'components/slider/slide_page.dart';
import 'components/state/state_page.dart';
import 'components/text/text_page.dart';
import 'convert/convert_page.dart';
import 'desktop/desktop_page.dart';
import 'desktop/screen_capture_page.dart';
import 'http/http_page.dart';
import 'load_image/load_image_page.dart';
import 'provider/provider_page.dart';
import 'router/router_page.dart';
import 'study_page.dart';
import 'video/video_page.dart';
import 'window/main_window_page.dart';

///
/// Created by a0010 on 2023/5/11 16:05
///
class StudyRouter {
  static const String study = '/study';
  static const String convert = '$study/convert';
  static const String http = '$study/http';
  static const String loadImage = '$study/loadImage';
  static const String provider = '$study/provider';
  static const String router = '$study/router';
  static const String video = '$study/video';
  static const String multiWindow = '$study/multiWindow';
  static const String desktop = '$study/desktop';
  static const String screenCapture = '$study/screenCapture';

  static const String components = '$study/components';
  static const String chat = '$components/chat';
  static const String city = '$components/city';
  static const String dialog = '$components/dialog';
  static const String dragList = '$components/dragList';
  static const String floatNavigation = '$components/floatNavigation';
  static const String image = '$components/image';
  static const String keyword = '$components/keyword';
  static const String list = '$components/list';
  static const String popup = '$components/popup';
  static const String qr = '$components/qr';
  static const String recording = '$components/recording';
  static const String slide = '$components/slide';
  static const String state = '$components/state';
  static const String text = '$components/text';

  static List<AppPageConfig> get routers => [
        AppPageConfig(study, builder: (settings) {
          return const StudyPage();
        }),
        AppPageConfig(convert, builder: (settings) {
          return const ConvertPage();
        }),
        AppPageConfig(http, builder: (settings) {
          return const HTTPListPage();
        }),
        AppPageConfig(loadImage, builder: (settings) {
          return const LoadImagePage();
        }),
        AppPageConfig(provider, builder: (settings) {
          return const ProviderPage();
        }),
        AppPageConfig(router, builder: (settings) {
          return const RouterPage();
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
        ...componentsRouter,
      ];

  static List<AppPageConfig> get componentsRouter => [
        AppPageConfig(components, builder: (settings) {
          return const ComponentsPage();
        }),
        AppPageConfig(chat, builder: (settings) {
          return const ChatPage();
        }),
        AppPageConfig(city, builder: (settings) {
          return const CitySelectedPage();
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
        AppPageConfig(image, builder: (settings) {
          return const ImageEditorPage();
        }),
        AppPageConfig(keyword, builder: (settings) {
          return const KeywordBoardPage();
        }),
        AppPageConfig(list, builder: (settings) {
          return const ListPage();
        }),
        AppPageConfig(popup, builder: (settings) {
          return const PopupPage();
        }),
        AppPageConfig(qr, builder: (settings) {
          return const QRPage();
        }),
        AppPageConfig(recording, builder: (settings) {
          return const RecordingPage();
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
      ];
}
