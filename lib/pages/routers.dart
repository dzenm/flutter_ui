import 'package:bot_toast/bot_toast.dart';
import 'package:fbl/fbl.dart';
import 'package:flutter/widgets.dart';

import 'common/city_select.dart';
import 'common/example.dart';
import 'common/view_media.dart';
import 'common/web_view.dart';
import 'login/login_page.dart';
import 'login/register_page.dart';
import 'main/home/home_page.dart';
import 'main/main_page.dart';
import 'main/me/me_page.dart';
import 'main/me/me_router.dart';
import 'main/nav/nav_page.dart';
import 'router_config.dart';

///
/// Created by a0010 on 2023/5/6 13:32
///
class Routers extends NavigatorObserver {
  static const String root = 'root';
  static const String login = 'login';
  static const String register = 'register';
  static const String main = 'main';
  static const String home = 'home';
  static const String nav = 'nav';
  static const String me = 'me';

  static const String citySelected = 'citySelected';
  static const String example = 'example';
  static const String webView = 'webView';
  static const String viewMedia = 'viewMedia';

  static final LoginAuth auth = LoginAuth();

  static final routes = ARouter(
    observers: [
      BotToastNavigatorObserver(),
      Routers(),
    ],
    debugLog: Log.d,
    initialLocation: mainPage,
    refreshListenable: auth,
    debugLogDiagnostics: true,
    redirect: _guard,
    routes: BuildConfig.isMobile //
        ? _RouterMobile.routers
        : _RouterDesktop.routers,
  );

  /// 路由守卫，判断是否需要拦截路由
  static String? _guard(BuildContext context, ARouterState state) {
    final bool signedIn = auth.signedIn;
    final bool signingIn = state.matchedLocation == '/$login';

    // Go to /login if the user is not signed in
    if (!signedIn && !signingIn) {
      return '/$login';
    }
    // Go to /main if the user is signed in and tries to go to /login.
    else if (signedIn && signingIn) {
      return '/$home';
    }

    // no redirect
    return null;
  }

  /// 初始页面
  static String get mainPage => SPManager.getUserLoginState() ? '/home' : '/login';

  /// 路由监听器
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => //
      log('didPush: ${route.str}, previousRoute= ${previousRoute?.str}');

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => //
      log('didPop: ${route.str}, previousRoute= ${previousRoute?.str}');

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => //
      log('didRemove: ${route.str}, previousRoute= ${previousRoute?.str}');

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => //
      log('didReplace: new= ${newRoute?.str}, old= ${oldRoute?.str}');

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) =>
      log('didStartUserGesture: ${route.str}, '
          'previousRoute= ${previousRoute?.str}');

  @override
  void didStopUserGesture() => log('didStopUserGesture');

  void log(String msg) {
    Log.i(msg, tag: 'Routers');
  }
}

extension on Route<dynamic> {
  String get str => 'route(${settings.name}: ${settings.arguments})';
}

class _RouterMobile {
  // Key必须唯一，重复创建会导致页面重新渲染
  static final GlobalKey<NavigatorState> _rootKey = GlobalKey(debugLabel: 'main');
  static final GlobalKey<NavigatorState> _homeKey = GlobalKey(debugLabel: 'home');
  static final GlobalKey<NavigatorState> _navKey = GlobalKey(debugLabel: 'nav');
  static final GlobalKey<NavigatorState> _meKey = GlobalKey(debugLabel: 'me');
  static List<RouteBase> routers = [
    ARoute(name: Routers.root, path: '/', redirect: (_, __) => Routers.mainPage),
    ARoute(
      name: Routers.login,
      path: '/login',
      pageBuilder: (context, state) => FadeTransitionPage(
        key: state.pageKey,
        child: LoginPage(),
      ),
    ),
    ARoute(
      name: Routers.register,
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    ARoute(name: Routers.main, path: '/main', redirect: (_, __) => '/home'),
    StatefulShellRoute(
      builder: (
        BuildContext context,
        ARouterState state,
        StatefulNavigationShell navigationShell,
      ) {
        // This nested StatefulShellRoute demonstrates the use of a
        // custom container for the branch Navigators. In this implementation,
        // no customization is done in the builder function (navigationShell
        // itself is simply used as the Widget for the route). Instead, the
        // navigatorContainerBuilder function below is provided to
        // customize the container for the branch Navigators.
        return navigationShell;
      },
      navigatorContainerBuilder: (
        BuildContext context,
        StatefulNavigationShell navigationShell,
        List<Widget> children,
      ) {
        // Returning a customized container for the branch
        // Navigators (i.e. the `List<Widget> children` argument).
        //
        // See ScaffoldWithNavBar for more details on how the children
        // are managed (using AnimatedBranchContainer).
        return MainPage(
          key: _rootKey,
          navigationShell: navigationShell,
          children: children,
        );
        // NOTE: To use a Cupertino version of MainPage, replace
        // MainPage above with CupertinoMainPage.
      },
      branches: <StatefulShellBranch>[
        // The route branch for the first tab of the bottom navigation bar.
        StatefulShellBranch(
          navigatorKey: _homeKey,
          routes: <RouteBase>[
            ARoute(
              // The screen to display as the root in the first tab of the
              // bottom navigation bar.
              name: Routers.home,
              path: '/home',
              builder: (BuildContext context, ARouterState state) => const HomePage(),
            ),
          ],
        ),

        // The route branch for the second tab of the bottom navigation bar.
        StatefulShellBranch(
          navigatorKey: _navKey,
          // To enable preloading of the initial locations of branches, pass
          // `true` for the parameter `preload` (`false` is default).
          preload: true,
          // StatefulShellBranch will automatically use the first descendant
          // GoRoute as the initial location of the branch. If another route
          // is desired, specify the location of it using the defaultLocation
          // parameter.
          initialLocation: '/nav',
          routes: <RouteBase>[
            ARoute(
              // The screen to display as the root in the first tab of the
              // bottom navigation bar.
              name: Routers.nav,
              path: '/nav',
              builder: (BuildContext context, ARouterState state) => const NavPage(),
            ),
            // StatefulShellRoute(
            //   builder: (
            //     BuildContext context,
            //     ARouterState state,
            //     StatefulNavigationShell navigationShell,
            //   ) {
            //     // Just like with the top level StatefulShellRoute, no
            //     // customization is done in the builder function.
            //     return navigationShell;
            //   },
            //   navigatorContainerBuilder: (BuildContext context, StatefulNavigationShell navigationShell, List<Widget> children) {
            //     // Returning a customized container for the branch
            //     // Navigators (i.e. the `List<Widget> children` argument).
            //     //
            //     // See TabbedRootScreen for more details on how the children
            //     // are managed (in a TabBarView).
            //     return TabbedRootScreen(
            //       navigationShell: navigationShell,
            //       key: tabbedRootScreenKey,
            //       children: children,
            //     );
            //     // NOTE: To use a PageView version of TabbedRootScreen,
            //     // replace TabbedRootScreen above with PagedRootScreen.
            //   },
            //   // This bottom tab uses a nested shell, wrapping sub routes in a
            //   // top TabBar.
            //   branches: <StatefulShellBranch>[
            //     StatefulShellBranch(navigatorKey: _tabB1NavigatorKey, routes: <GoRoute>[
            //       GoRoute(
            //         path: '/b1',
            //         builder: (BuildContext context, GoRouterState state) => const TabScreen(label: 'B1', detailsPath: '/b1/details'),
            //         routes: <RouteBase>[
            //           GoRoute(
            //             path: 'details',
            //             builder: (BuildContext context, GoRouterState state) => const DetailsScreen(
            //               label: 'B1',
            //               withScaffold: false,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ]),
            //     StatefulShellBranch(
            //         navigatorKey: _tabB2NavigatorKey,
            //         // To enable preloading for all nested branches, set
            //         // `preload` to `true` (`false` is default).
            //         preload: true,
            //         routes: <GoRoute>[
            //           GoRoute(
            //             path: '/b2',
            //             builder: (BuildContext context, GoRouterState state) => const TabScreen(label: 'B2', detailsPath: '/b2/details'),
            //             routes: <RouteBase>[
            //               GoRoute(
            //                 path: 'details',
            //                 builder: (BuildContext context, GoRouterState state) => const DetailsScreen(
            //                   label: 'B2',
            //                   withScaffold: false,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ]),
            //   ],
            // ),
          ],
        ),

        // The route branch for the third tab of the bottom navigation bar.
        StatefulShellBranch(
          navigatorKey: _meKey,
          preload: true,
          initialLocation: '/me',
          routes: <RouteBase>[
            ARoute(
              name: MeRouter.me,
              path: '/me',
              builder: (context, state) => const MePageMobile(),
            )
          ],
        ),
      ],
    ),
    ...MeRouter.routers,
    CommonRouters.citySelected,
    CommonRouters.example,
    CommonRouters.webView,
    CommonRouters.viewMedia,
  ];
}

class _RouterDesktop {
  static final GlobalKey<NavigatorState> _rootKey = GlobalKey(debugLabel: 'main');
  static final GlobalKey<NavigatorState> _homeKey = GlobalKey(debugLabel: 'home');
  static final GlobalKey<NavigatorState> _navKey = GlobalKey(debugLabel: 'nav');
  static final GlobalKey<NavigatorState> _meKey = GlobalKey(debugLabel: 'me');
  static List<RouteBase> routers = [
    ARoute(name: Routers.root, path: '/', redirect: (_, __) => Routers.mainPage),
    ARoute(
      name: Routers.login,
      path: '/login',
      pageBuilder: (context, state) => FadeTransitionPage(
        key: state.pageKey,
        child: LoginPage(),
      ),
    ),
    ARoute(
      name: Routers.register,
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    ARoute(name: Routers.main, path: '/main', redirect: (_, __) => '/home'),
    StatefulShellRoute(
      builder: (
        BuildContext context,
        ARouterState state,
        StatefulNavigationShell navigationShell,
      ) {
        // This nested StatefulShellRoute demonstrates the use of a
        // custom container for the branch Navigators. In this implementation,
        // no customization is done in the builder function (navigationShell
        // itself is simply used as the Widget for the route). Instead, the
        // navigatorContainerBuilder function below is provided to
        // customize the container for the branch Navigators.
        return navigationShell;
      },
      navigatorContainerBuilder: (
        BuildContext context,
        StatefulNavigationShell navigationShell,
        List<Widget> children,
      ) {
        // Returning a customized container for the branch
        // Navigators (i.e. the `List<Widget> children` argument).
        //
        // See ScaffoldWithNavBar for more details on how the children
        // are managed (using AnimatedBranchContainer).
        return MainPage(
          key: _rootKey,
          navigationShell: navigationShell,
          children: children,
        );
        // NOTE: To use a Cupertino version of MainPage, replace
        // MainPage above with CupertinoMainPage.
      },
      branches: <StatefulShellBranch>[
        // The route branch for the first tab of the bottom navigation bar.
        StatefulShellBranch(
          navigatorKey: _homeKey,
          routes: <RouteBase>[
            ARoute(
              // The screen to display as the root in the first tab of the
              // bottom navigation bar.
              name: Routers.home,
              path: '/home',
              builder: (BuildContext context, ARouterState state) => const HomePage(),
            ),
          ],
        ),

        // The route branch for the second tab of the bottom navigation bar.
        StatefulShellBranch(
          navigatorKey: _navKey,
          // To enable preloading of the initial locations of branches, pass
          // `true` for the parameter `preload` (`false` is default).
          preload: true,
          // StatefulShellBranch will automatically use the first descendant
          // GoRoute as the initial location of the branch. If another route
          // is desired, specify the location of it using the defaultLocation
          // parameter.
          initialLocation: '/nav',
          routes: <RouteBase>[
            ARoute(
              // The screen to display as the root in the first tab of the
              // bottom navigation bar.
              name: Routers.nav,
              path: '/nav',
              builder: (BuildContext context, ARouterState state) => const NavPage(),
            ),
            // StatefulShellRoute(
            //   builder: (
            //     BuildContext context,
            //     ARouterState state,
            //     StatefulNavigationShell navigationShell,
            //   ) {
            //     // Just like with the top level StatefulShellRoute, no
            //     // customization is done in the builder function.
            //     return navigationShell;
            //   },
            //   navigatorContainerBuilder: (BuildContext context, StatefulNavigationShell navigationShell, List<Widget> children) {
            //     // Returning a customized container for the branch
            //     // Navigators (i.e. the `List<Widget> children` argument).
            //     //
            //     // See TabbedRootScreen for more details on how the children
            //     // are managed (in a TabBarView).
            //     return TabbedRootScreen(
            //       navigationShell: navigationShell,
            //       key: tabbedRootScreenKey,
            //       children: children,
            //     );
            //     // NOTE: To use a PageView version of TabbedRootScreen,
            //     // replace TabbedRootScreen above with PagedRootScreen.
            //   },
            //   // This bottom tab uses a nested shell, wrapping sub routes in a
            //   // top TabBar.
            //   branches: <StatefulShellBranch>[
            //     StatefulShellBranch(navigatorKey: _tabB1NavigatorKey, routes: <GoRoute>[
            //       GoRoute(
            //         path: '/b1',
            //         builder: (BuildContext context, GoRouterState state) => const TabScreen(label: 'B1', detailsPath: '/b1/details'),
            //         routes: <RouteBase>[
            //           GoRoute(
            //             path: 'details',
            //             builder: (BuildContext context, GoRouterState state) => const DetailsScreen(
            //               label: 'B1',
            //               withScaffold: false,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ]),
            //     StatefulShellBranch(
            //         navigatorKey: _tabB2NavigatorKey,
            //         // To enable preloading for all nested branches, set
            //         // `preload` to `true` (`false` is default).
            //         preload: true,
            //         routes: <GoRoute>[
            //           GoRoute(
            //             path: '/b2',
            //             builder: (BuildContext context, GoRouterState state) => const TabScreen(label: 'B2', detailsPath: '/b2/details'),
            //             routes: <RouteBase>[
            //               GoRoute(
            //                 path: 'details',
            //                 builder: (BuildContext context, GoRouterState state) => const DetailsScreen(
            //                   label: 'B2',
            //                   withScaffold: false,
            //                 ),
            //               ),
            //             ],
            //           ),
            //         ]),
            //   ],
            // ),
          ],
        ),

        // The route branch for the third tab of the bottom navigation bar.
        StatefulShellBranch(
          navigatorKey: _meKey,
          preload: true,
          routes: MeRouter.routers,
        ),
      ],
    ),
  ];
}

class CommonRouters {
  static ARoute citySelected = ARoute(
    name: Routers.citySelected,
    path: '/citySelected',
    builder: (context, state) => const CitySelectedPage(),
  );
  static ARoute example = ARoute(
    name: Routers.example,
    path: '/example',
    builder: (context, state) => const ExamplePage(),
  );
  static ARoute webView = ARoute(
    name: Routers.webView,
    path: '/webView',
    builder: (context, state) {
      dynamic args = state.uri.queryParameters;
      String title = args['title'] ?? '';
      String url = args['url'] ?? '';
      return WebViewPage(title: title, url: url);
    },
  );
  static ARoute viewMedia = ARoute(
    name: Routers.viewMedia,
    path: '/viewMedia',
    builder: (context, state) {
      dynamic args = state.uri.queryParameters;
      String title = args['title'] ?? '';
      String url = args['url'] ?? '';
      return const ViewMediaPage(medias: []);
    },
  );
}
