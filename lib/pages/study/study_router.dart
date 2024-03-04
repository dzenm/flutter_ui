import 'package:flutter_ui/pages/study/chat_page/chat_page.dart';
import 'package:flutter_ui/pages/study/window_page/main_window_page.dart';

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
import 'router_page/router_page.dart';
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
      ];
}
