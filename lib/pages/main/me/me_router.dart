import '../../../base/a_router/route.dart';
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
  static const String me = 'me';
  static const String article = 'article';
  static const String coin = 'coin';
  static const String collect = 'collect';
  static const String medicine = 'medicine';
  static const String rank = 'rank';

  static const String info = 'info';
  static const String viewInfo = 'viewInfo';
  static const String editInfo = 'editInfo';

  static const String setting = 'setting';
  static const String about = 'about';

  static List<RouteBase> get routers => [
        ARoute(
            name: article,
            path: 'article',
            builder: (context, state) {
              return const ArticlePage();
            }),
        ARoute(
            name: coin,
            path: 'coin',
            builder: (context, state) {
              return const CoinPage();
            }),
        ARoute(
            name: collect,
            path: 'collect',
            builder: (context, state) {
              return const CollectPage();
            }),
        ARoute(
            name: medicine,
            path: 'medicine',
            builder: (context, state) {
              dynamic params = state.uri.queryParameters;
              String medicineName = params['medicineName'] ?? '';
              return MedicinePage(medicineName: medicineName);
            }),
        ARoute(
            name: rank,
            path: 'rank',
            builder: (context, state) {
              return const RankPage();
            }),
        ARoute(
          name: info,
          path: 'info',
          builder: (context, state) {
            return const InfoPage();
          },
          routes: [
            ARoute(
                name: editInfo,
                path: 'edit',
                builder: (context, state) {
                  return const EditInfoPage();
                }),
            ARoute(
                name: viewInfo,
                path: 'view',
                builder: (context, state) {
                  return const ViewInfoPage();
                }),
          ],
        ),
        ARoute(
          name: setting,
          path: 'setting',
          builder: (context, state) {
            return const SettingPage();
          },
          routes: [
            ARoute(
                name: about,
                path: 'about',
                builder: (context, state) {
                  return const AboutPage();
                }),
          ],
        ),
      ];
}
