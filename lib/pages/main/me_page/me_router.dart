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
  static final String setting = '$me/setting';
  static final String editInfo = '$me/editInfo';
  static final String viewInfo = '$me/viewInfo';

  static List<AppRoutePage> get routers => [
        AppRoutePage(
          name: article,
          builder: (setting) {
            return ArticlePage();
          },
        ),
        AppRoutePage(
          name: coin,
          builder: (setting) {
            return CoinPage();
          },
        ),
        AppRoutePage(
          name: collect,
          builder: (setting) {
            return CollectPage();
          },
        ),
        AppRoutePage(
          name: medicine,
          builder: (setting) {
            dynamic params = setting.params;
            String medicineName = params['medicineName'] ?? '';
            return MedicinePage(medicineName: medicineName);
          },
        ),
        AppRoutePage(
          name: rank,
          builder: (setting) {
            return RankPage();
          },
        ),
        AppRoutePage(
          name: setting,
          builder: (setting) {
            return SettingPage();
          },
        ),
        AppRoutePage(
          name: editInfo,
          builder: (setting) {
            return EditInfoPage();
          },
        ),
        AppRoutePage(
          name: viewInfo,
          builder: (setting) {
            return ViewInfoPage();
          },
        ),
      ];
}
