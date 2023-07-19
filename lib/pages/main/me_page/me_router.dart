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
  static final String me = '/me';
  static final String article = '$me/article';
  static final String coin = '$me/coin';
  static final String collect = '$me/collect';
  static final String medicine = '$me/medicine';
  static final String rank = '$me/rank';

  static final String info = '$me/info';
  static final String viewInfo = '$me/$info/viewInfo';
  static final String editInfo = '$me/$info/editInfo';

  static final String setting = '$me/setting';
  static final String about = '$me/$setting/about';

  static List<AppRoutePage> get routers => [
        AppRoutePage(
          name: article,
          builder: (settings) {
            return ArticlePage();
          },
        ),
        AppRoutePage(
          name: coin,
          builder: (settings) {
            return CoinPage();
          },
        ),
        AppRoutePage(
          name: collect,
          builder: (settings) {
            return CollectPage();
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
            return RankPage();
          },
        ),
        AppRoutePage(
          name: info,
          builder: (settings) {
            return InfoPage();
          },
        ),
        AppRoutePage(
          name: editInfo,
          builder: (settings) {
            return EditInfoPage();
          },
        ),
        AppRoutePage(
          name: viewInfo,
          builder: (settings) {
            return ViewInfoPage();
          },
        ),
        AppRoutePage(
          name: setting,
          builder: (settings) {
            return SettingPage();
          },
        ),
        AppRoutePage(
          name: about,
          builder: (settings) {
            return AboutPage();
          },
        ),
      ];
}
