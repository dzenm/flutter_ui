import 'package:fbl/fbl.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_ui/pages/mall/mall_router.dart';
import 'package:go_router/go_router.dart';

import '../../study/study_page.dart';
import '../../study/study_router.dart';
import 'article/article_page.dart';
import 'coin/coin_page.dart';
import 'collect/collect_page.dart';
import 'info/edit_info_page.dart';
import 'info/info_page.dart';
import 'info/view_info_page.dart';
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
  static const String medicine = 'medicine';
  static const String collect = 'collect';
  static const String coin = 'coin';
  static const String rank = 'rank';
  static const String article = 'article';

  static const String info = 'info';
  static const String viewInfo = 'viewInfo';
  static const String editInfo = 'editInfo';

  static const String setting = 'setting';
  static const String about = 'about';

  static List<RouteBase> get routers => BuildConfig.isMobile //
      ? _MeRouterMobile.routers
      : [_MeRouterDesktop.routers];

  static int getPathIndex(String path) => _MeRouterDesktop.getPathIndex(path);
}

class _MeRouterMobile {
  static List<RouteBase> get routers => [
        GoRoute(
          name: MeRouter.medicine,
          path: '/medicine',
          builder: (context, state) => const MedicinePage(medicineName: '金银花'),
        ),
        GoRoute(
          name: MeRouter.collect,
          path: '/collect',
          builder: (context, state) => const CollectPage(),
        ),
        GoRoute(
          name: MeRouter.coin,
          path: '/coin',
          builder: (context, state) => const CoinPage(),
        ),
        GoRoute(
          name: MeRouter.rank,
          path: '/rank',
          builder: (context, state) => const RankPage(),
        ),
        GoRoute(
          name: MeRouter.article,
          path: '/article',
          builder: (context, state) => const ArticlePage(),
        ),
        GoRoute(
          name: StudyRouter.study,
          path: '/study',
          builder: (context, state) {
            return const StudyPage();
          },
          routes: StudyRouter.routers,
        ),
        GoRoute(
          name: MeRouter.info,
          path: '/info',
          builder: (context, state) => const InfoPage(),
          routes: [
            GoRoute(
              name: MeRouter.editInfo,
              path: '/edit',
              builder: (context, state) => const EditInfoPage(),
            ),
            GoRoute(
              name: MeRouter.viewInfo,
              path: '/view',
              builder: (context, state) => const ViewInfoPage(),
            ),
          ],
        ),
        ...MallRouter.routers,
        GoRoute(
          name: MeRouter.setting,
          path: '/setting',
          builder: (context, state) => const SettingPage(),
          routes: [
            GoRoute(
              name: MeRouter.about,
              path: '/about',
              builder: (context, state) => const AboutPage(),
            ),
          ],
        ),
      ];
}

class _MeRouterDesktop {
  static const ValueKey<String> _meRootKey = ValueKey('meRoot');
  static final GlobalKey<NavigatorState> _medicineKey = GlobalKey(debugLabel: 'medicine');
  static final GlobalKey<NavigatorState> _collectKey = GlobalKey(debugLabel: 'collect');
  static final GlobalKey<NavigatorState> _coinKey = GlobalKey(debugLabel: 'coin');
  static final GlobalKey<NavigatorState> _rankKey = GlobalKey(debugLabel: 'rank');
  static final GlobalKey<NavigatorState> _articleKey = GlobalKey(debugLabel: 'article');
  static final GlobalKey<NavigatorState> _studyKey = GlobalKey(debugLabel: 'study');
  static final GlobalKey<NavigatorState> _infoKey = GlobalKey(debugLabel: 'info');
  static final GlobalKey<NavigatorState> _mallKey = GlobalKey(debugLabel: 'mall');
  static final GlobalKey<NavigatorState> _settingKey = GlobalKey(debugLabel: 'setting');

  static RouteBase get routers => StatefulShellRoute(
        builder: (context, state, navigationShell) {
          // Just like with the top level StatefulShellRoute, no
          // customization is done in the builder function.
          return navigationShell;
        },
        navigatorContainerBuilder: (context, navigationShell, children) {
          // Returning a customized container for the branch
          // Navigators (i.e. the `List<Widget> children` argument).
          //
          // See TabbedRootScreen for more details on how the children
          // are managed (in a TabBarView).
          return MePageDesktop(
            key: _meRootKey,
            navigationShell: navigationShell,
            children: children,
          );
          // NOTE: To use a PageView version of MePage,
          // replace MePage above with MePage.
        },
        // This bottom tab uses a nested shell, wrapping sub routes in a
        // top TabBar.
        branches: [
          StatefulShellBranch(
            navigatorKey: _medicineKey,
            routes: [
              GoRoute(
                name: MeRouter.medicine,
                path: '/medicine',
                builder: (context, state) => const MedicinePage(medicineName: '金银花'),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _collectKey,
            routes: [
              GoRoute(
                name: MeRouter.collect,
                path: '/collect',
                builder: (context, state) => const CollectPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _coinKey,
            routes: [
              GoRoute(
                name: MeRouter.coin,
                path: '/coin',
                builder: (context, state) => const CoinPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _rankKey,
            routes: [
              GoRoute(
                name: MeRouter.rank,
                path: '/rank',
                builder: (context, state) => const RankPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _articleKey,
            routes: [
              GoRoute(
                name: MeRouter.article,
                path: '/article',
                builder: (context, state) => const ArticlePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _studyKey,
            routes: [
              GoRoute(
                name: StudyRouter.study,
                path: '/study',
                builder: (context, state) {
                  return const StudyPage();
                },
                routes: StudyRouter.routers,
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _infoKey,
            routes: [
              GoRoute(
                name: MeRouter.info,
                path: '/info',
                builder: (context, state) => const InfoPage(),
                routes: [
                  GoRoute(
                    name: MeRouter.editInfo,
                    path: '/edit',
                    builder: (context, state) => const EditInfoPage(),
                  ),
                  GoRoute(
                    name: MeRouter.viewInfo,
                    path: '/view',
                    builder: (context, state) => const ViewInfoPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _mallKey,
            routes: MallRouter.routers,
          ),
          StatefulShellBranch(
            navigatorKey: _settingKey,
            routes: [
              GoRoute(
                name: MeRouter.setting,
                path: '/setting',
                builder: (context, state) => const SettingPage(),
                routes: [
                  GoRoute(
                    name: MeRouter.about,
                    path: '/about',
                    builder: (context, state) => const AboutPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      );

  /// [routers] 是一个StatefulShellRoute，通过index切换
  static int getPathIndex(String path) {
    int index = 0;
    if (path == MeRouter.medicine) {
      index = 0;
    } else if (path == MeRouter.collect) {
      index = 1;
    } else if (path == MeRouter.coin) {
      index = 2;
    } else if (path == MeRouter.rank) {
      index = 3;
    } else if (path == MeRouter.article) {
      index = 4;
    } else if (path == StudyRouter.study) {
      index = 5;
    } else if (path == MeRouter.info) {
      index = 6;
    } else if (path == MallRouter.mall) {
      index = 7;
    } else if (path == MeRouter.setting) {
      index = 8;
    }
    return index;
  }
}
