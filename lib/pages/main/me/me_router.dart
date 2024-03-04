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
  static const String editInfo = '$info/editInfo/:id';

  static const String setting = '$me/setting';
  static const String about = '$setting/about';

  static List<AppPageConfig> get routers => [
        AppPageConfig(article, builder: (settings) {
          return const ArticlePage();
        }),
        AppPageConfig(coin, builder: (settings) {
          return const CoinPage();
        }),
        AppPageConfig(collect, builder: (settings) {
          return const CollectPage();
        }),
        AppPageConfig(medicine, builder: (settings) {
          dynamic params = settings.queryParameters;
          String medicineName = params['medicineName'] ?? '';
          return MedicinePage(medicineName: medicineName);
        }),
        AppPageConfig(rank, builder: (settings) {
          return const RankPage();
        }),
        AppPageConfig(info, builder: (settings) {
          return const InfoPage();
        }),
        AppPageConfig(editInfo, builder: (settings) {
          Log.d('接收的数据：settings=${settings.toString()}');
          return const EditInfoPage();
        }),
        AppPageConfig(viewInfo, builder: (settings) {
          return const ViewInfoPage();
        }),
        AppPageConfig(setting, builder: (settings) {
          return const SettingPage();
        }),
        AppPageConfig(about, builder: (settings) {
          return const AboutPage();
        }),
      ];
}
