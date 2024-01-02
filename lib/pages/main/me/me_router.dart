import '../../../base/base.dart';
import 'article/article_page.dart';
import 'coin/coin_page.dart';
import 'collect/collect_page.dart';
import 'info/edit_info_page.dart';
import 'info/info_page.dart';
import 'info/view_info_page.dart';
import 'medicine/medicine_page.dart';
import 'rank/rank_page.dart';
import 'setting/about/about_page.dart';
import 'setting/setting_page.dart';

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
  static const String viewInfo = '$info/viewInfo';
  static const String editInfo = '$info/editInfo';

  static const String setting = '$me/setting';
  static const String about = '$setting/about';

  static List<AppPageConfig> get routers => [
        AppPageConfig(
          name: article,
          builder: (settings) {
            return const ArticlePage();
          },
        ),
        AppPageConfig(
          name: coin,
          builder: (settings) {
            return const CoinPage();
          },
        ),
        AppPageConfig(
          name: collect,
          builder: (settings) {
            return const CollectPage();
          },
        ),
        AppPageConfig(
          name: medicine,
          builder: (settings) {
            dynamic params = settings.queries;
            String medicineName = params['medicineName'] ?? '';
            return MedicinePage(medicineName: medicineName);
          },
        ),
        AppPageConfig(
          name: rank,
          builder: (settings) {
            return const RankPage();
          },
        ),
        AppPageConfig(
          name: info,
          builder: (settings) {
            return const InfoPage();
          },
        ),
        AppPageConfig(
          name: editInfo,
          builder: (settings) {
            Log.d('接受的数据：name=${settings.name}');
            Log.d('接受的数据：arguments=${settings.arguments}');
            Log.d('接受的数据：originPath=${settings.originPath}');
            Log.d('接受的数据：paths=${settings.paths}');
            Log.d('接受的数据：queries=${settings.queries}');
            return const EditInfoPage();
          },
        ),
        AppPageConfig(
          name: viewInfo,
          builder: (settings) {
            return const ViewInfoPage();
          },
        ),
        AppPageConfig(
          name: setting,
          builder: (settings) {
            return const SettingPage();
          },
        ),
        AppPageConfig(
          name: about,
          builder: (settings) {
            return const AboutPage();
          },
        ),
      ];
}
