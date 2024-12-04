import 'package:fbl/fbl.dart';

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
import 'video/video_page.dart';
import 'window/main_window_page.dart';

///
/// Created by a0010 on 2023/5/11 16:05
///
class StudyRouter {
  static const String study = 'study';
  static const String convert = 'convert';
  static const String http = 'http';
  static const String loadImage = 'loadImage';
  static const String provider = 'provider';
  static const String router = 'router';
  static const String video = 'video';
  static const String multiWindow = 'multiWindow';
  static const String desktop = 'desktop';
  static const String screenCapture = 'screenCapture';

  static const String components = 'components';
  static const String chat = 'chat';
  static const String city = 'city';
  static const String dialog = 'dialog';
  static const String dragList = 'dragList';
  static const String floatNavigation = 'floatNavigation';
  static const String image = 'image';
  static const String keyword = 'keyword';
  static const String list = 'list';
  static const String popup = 'popup';
  static const String qr = 'qr';
  static const String recording = 'recording';
  static const String slide = 'slide';
  static const String state = 'state';
  static const String text = 'text';

  static List<RouteBase> get routers => [
        ARoute(
          name: convert,
          path: '/convert',
          builder: (context, state) {
            return const ConvertPage();
          },
        ),
        ARoute(
          name: components,
          path: '/components',
          builder: (context, state) {
            return const ComponentsPage();
          },
          routes: componentsRouter,
        ),
        ARoute(
          name: http,
          path: '/http',
          builder: (context, state) {
            return const HTTPListPage();
          },
        ),
        ARoute(
          name: loadImage,
          path: '/loadImage',
          builder: (context, state) {
            return const LoadImagePage();
          },
        ),
        ARoute(
          name: provider,
          path: '/provider',
          builder: (context, state) {
            return const ProviderPage();
          },
        ),
        ARoute(
          name: router,
          path: '/router',
          builder: (context, state) {
            return const RouterPage();
          },
        ),
        ARoute(
          name: video,
          path: '/video',
          builder: (context, state) {
            return const VideoPage();
          },
        ),
        ARoute(
          name: multiWindow,
          path: '/multiWindow',
          builder: (context, state) {
            return const MainWindowPage();
          },
        ),
        ARoute(
          name: desktop,
          path: '/desktop',
          builder: (context, state) {
            return const DesktopPage();
          },
        ),
        ARoute(
          name: screenCapture,
          path: '/screenCapture',
          builder: (context, state) {
            return const ScreenCapturePage();
          },
        ),
      ];

  static List<ARoute> get componentsRouter => [
        ARoute(
          name: chat,
          path: '/chat',
          builder: (context, state) {
            return const ChatPage();
          },
        ),
        ARoute(
          name: city,
          path: '/city',
          builder: (context, state) {
            return const CitySelectedPage();
          },
        ),
        ARoute(
          name: dialog,
          path: '/dialog',
          builder: (context, state) {
            return const DialogPage();
          },
        ),
        ARoute(
          name: dragList,
          path: '/dragList',
          builder: (context, state) {
            return const DragListPage();
          },
        ),
        ARoute(
          name: floatNavigation,
          path: '/floatNavigation',
          builder: (context, state) {
            return const FloatNavigationPage();
          },
        ),
        ARoute(
          name: image,
          path: '/image',
          builder: (context, state) {
            return const ImageEditorPage();
          },
        ),
        ARoute(
          name: keyword,
          path: '/keyword',
          builder: (context, state) {
            return const KeywordBoardPage();
          },
        ),
        ARoute(
          name: list,
          path: '/list',
          builder: (context, state) {
            return const ListPage();
          },
        ),
        ARoute(
          name: popup,
          path: '/popup',
          builder: (context, state) {
            return const PopupPage();
          },
        ),
        ARoute(
          name: qr,
          path: '/qr',
          builder: (context, state) {
            return const QRPage();
          },
        ),
        ARoute(
          name: recording,
          path: '/recording',
          builder: (context, state) {
            return const RecordingPage();
          },
        ),
        ARoute(
          name: slide,
          path: '/slide',
          builder: (context, state) {
            return const SlidePage();
          },
        ),
        ARoute(
          name: state,
          path: '/state',
          builder: (context, state) {
            return const StatePage();
          },
        ),
        ARoute(
          name: text,
          path: '/text',
          builder: (context, state) {
            return const TextPage();
          },
        ),
      ];
}
