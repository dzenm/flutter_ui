import 'package:fbl/fbl.dart';
import 'package:flutter/widgets.dart';

import 'article/article_page.dart';
import 'coin/coin_page.dart';
import 'collect/collect_page.dart';
import 'info/edit_info_page.dart';
import 'info/info_page.dart';
import 'info/view_info_page.dart';
import 'me_content_page.dart';
import 'me_page.dart';
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

  static final GlobalKey<NavigatorState> _meKey = GlobalKey();

  static List<RouteBase> get routers => [...(BuildConfig.isMobile ? mobileRouters : desktopRouters)];

  static List<RouteBase> get mobileRouters => [
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
              return const MedicinePage(medicineName: '金银花');
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

  static List<RouteBase> get desktopRouters => [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigation) {
            return const MeContentPage();
          },
          branches: [
            StatefulShellBranch(navigatorKey: _meKey, routes: [
              ARoute(
                name: article,
                path: 'article',
                builder: (context, state) => const ArticlePage(),
              ),
            ]),
            StatefulShellBranch(routes: [
              ARoute(
                name: coin,
                path: 'coin',
                builder: (context, state) => const CoinPage(),
              ),
            ]),
            StatefulShellBranch(routes: [
              ARoute(
                name: collect,
                path: 'collect',
                builder: (context, state) => const CollectPage(),
              ),
            ]),
            StatefulShellBranch(routes: [
              ARoute(
                name: medicine,
                path: 'medicine',
                builder: (context, state) {
                  return const MedicinePage(medicineName: '金银花');
                },
              ),
            ]),
            StatefulShellBranch(routes: [
              ARoute(
                name: rank,
                path: 'rank',
                builder: (context, state) => const RankPage(),
              ),
            ]),
            StatefulShellBranch(routes: [
              ARoute(
                name: info,
                path: 'info',
                builder: (context, state) => const InfoPage(),
                routes: [
                  ARoute(
                    name: editInfo,
                    path: 'edit',
                    builder: (context, state) => const EditInfoPage(),
                  ),
                  ARoute(
                    name: viewInfo,
                    path: 'view',
                    builder: (context, state) => const ViewInfoPage(),
                  ),
                ],
              ),
            ]),
            StatefulShellBranch(routes: [
              ARoute(
                name: setting,
                path: 'setting',
                builder: (context, state) => const SettingPage(),
                routes: [
                  ARoute(
                    name: about,
                    path: 'about',
                    builder: (context, state) => const AboutPage(),
                  ),
                ],
              ),
            ]),
          ],
        ),
      ];
}
