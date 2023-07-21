import 'package:flutter_ui/pages/main/me_page/info/info_page.dart';
import 'package:flutter_ui/pages/main/me_page/setting_page/about/about_page.dart';

import '../../../base/route/app_route_delegate.dart';
import 'article/article_page.dart';
import 'coin/coin_page.dart';
import 'collect/collect_page.dart';
import 'info/edit_info_page.dart';
import 'info/view_info_page.dart';
import 'medicine/medicine_page.dart';
import 'rank/rank_page.dart';
import 'setting_page/setting_page.dart';

///
/// Created by a0010 on 2023/5/23 14:50
///
class MeRouter {
  static const String me = '/me';
  static const String article = '$me/article';
  static const String coin = '$me/coin';
  static const String collect = '$me/collect';
  static const String medicine = '$me/medicine';
  static const String rank = '$me/rank';

  static const String info = '$me/info';
  static const String viewInfo = '$me/$info/viewInfo';
  static const String editInfo = '$me/$info/editInfo';

  static const String setting = '$me/setting';
  static const String about = '$me/$setting/about';

  static List<AppRoutePage> get routers => [
        AppRoutePage(
          name: article,
          builder: (settings) {
            return const ArticlePage();
          },
        ),
        AppRoutePage(
          name: coin,
          builder: (settings) {
            return const CoinPage();
          },
        ),
        AppRoutePage(
          name: collect,
          builder: (settings) {
            return const CollectPage();
          },
        ),
        AppRoutePage(
          name: medicine,
          builder: (settings) {
            dynamic params = settings.params;
            String medicineName = params['medicineName'] ?? '';
            return MedicinePage(medicineName: medicineName);
          },
        ),
        AppRoutePage(
          name: rank,
          builder: (settings) {
            return const RankPage();
          },
        ),
        AppRoutePage(
          name: info,
          builder: (settings) {
            return const InfoPage();
          },
        ),
        AppRoutePage(
          name: editInfo,
          builder: (settings) {
            return const EditInfoPage();
          },
        ),
        AppRoutePage(
          name: viewInfo,
          builder: (settings) {
            return const ViewInfoPage();
          },
        ),
        AppRoutePage(
          name: setting,
          builder: (settings) {
            return const SettingPage();
          },
        ),
        AppRoutePage(
          name: about,
          builder: (settings) {
            return const AboutPage();
          },
        ),
      ];
}
