import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'configuration.dart';
import 'delegate.dart';
import 'information_provider.dart';
import 'match.dart';
import 'misc/inherited_router.dart';
import 'parser.dart';
import 'route.dart';
import 'state.dart';

/// The function signature of [ARouter.onException].
///
/// Use `state.error` to access the exception.
typedef GoExceptionHandler = void Function(
  BuildContext context,
  ARouterState state,
  ARouter router,
);

typedef Printer = void Function(String message, {String tag});

/// A set of parameters that defines routing in ARouter.
///
/// This is typically used with [ARouter.routingConfig] to create a go router
/// with dynamic routing config.
///
/// {@category Configuration}
class RoutingConfig {
  /// Creates a routing config.
  ///
  /// The [routes] must not be empty.
  const RoutingConfig({
    required this.routes,
    this.redirect = _defaultRedirect,
    this.redirectLimit = 5,
    this.debugLog,
  });

  static FutureOr<String?> _defaultRedirect(
          BuildContext context, ARouterState state) =>
      null;

  /// The supported routes.
  ///
  /// The `routes` list specifies the top-level routes for the app. It must not be
  /// empty and must contain an [ARoute] to match `/`.
  ///
  /// See [ARouter].
  final List<RouteBase> routes;

  /// The top-level callback allows the app to redirect to a new location.
  ///
  /// Alternatively, you can specify a redirect for an individual route using
  /// [ARoute.redirect]. If [BuildContext.dependOnInheritedWidgetOfExactType] is
  /// used during the redirection (which is how `of` methods are usually
  /// implemented), a re-evaluation will be triggered when the [InheritedWidget]
  /// changes.
  ///
  /// See [ARouter].
  final ARouterRedirect redirect;

  /// The maximum number of redirection allowed.
  ///
  /// See [ARouter].
  final int redirectLimit;

  final Printer? debugLog;
}

/// The route configuration for the app.
///
/// The `routes` list specifies the top-level routes for the app. It must not be
/// empty and must contain an [ARoute] to match `/`.
///
/// The [redirect] callback allows the app to redirect to a new location.
/// Alternatively, you can specify a redirect for an individual route using
/// [ARoute.redirect]. If [BuildContext.dependOnInheritedWidgetOfExactType] is
/// used during the redirection (which is how `of` methods are usually
/// implemented), a re-evaluation will be triggered when the [InheritedWidget]
/// changes.
///
/// To handle exceptions, use one of `onException`, `errorBuilder`, or
/// `errorPageBuilder`. The `onException` is called when an exception is thrown.
/// If `onException` is not provided, the exception is passed to
/// `errorPageBuilder` to build a page for the Router if it is not null;
/// otherwise, it is passed to `errorBuilder` instead. If none of them are
/// provided, go_router builds a default error screen to show the exception.
///
/// To disable automatically requesting focus when new routes are pushed to the navigator, set `requestFocus` to false.
/// {@category Get started}
/// {@category Upgrading}
/// {@category Configuration}
/// {@category Navigation}
/// {@category Redirection}
/// {@category Web}
/// {@category Deep linking}
/// {@category Error handling}
/// {@category Named routes}
class ARouter implements RouterConfig<RouteMatchList> {
  /// Default constructor to configure a ARouter with a routes builder
  /// and an error page builder.
  ///
  /// The `routes` must not be null and must contain an [ARouter] to match `/`.
  factory ARouter({
    required List<RouteBase> routes,
    Codec<Object?, Object?>? extraCodec,
    GoExceptionHandler? onException,
    ARouterPageBuilder? errorPageBuilder,
    ARouterWidgetBuilder? errorBuilder,
    ARouterRedirect? redirect,
    Listenable? refreshListenable,
    int redirectLimit = 5,
    bool routerNeglect = false,
    String? initialLocation,
    bool overridePlatformDefaultLocation = false,
    Object? initialExtra,
    List<NavigatorObserver>? observers,
    GlobalKey<NavigatorState>? navigatorKey,
    String? restorationScopeId,
    bool requestFocus = true,
    Printer? debugLog,
  }) {
    ValueNotifier<RoutingConfig> routingConfig = ValueNotifier(
      RoutingConfig(
        routes: routes,
        redirect: redirect ?? RoutingConfig._defaultRedirect,
        redirectLimit: redirectLimit,
        debugLog: debugLog,
      ),
    );
    return ARouter.routingConfig(
      routingConfig: routingConfig,
      extraCodec: extraCodec,
      onException: onException,
      errorPageBuilder: errorPageBuilder,
      errorBuilder: errorBuilder,
      refreshListenable: refreshListenable,
      routerNeglect: routerNeglect,
      initialLocation: initialLocation,
      overridePlatformDefaultLocation: overridePlatformDefaultLocation,
      initialExtra: initialExtra,
      observers: observers,
      navigatorKey: navigatorKey,
      restorationScopeId: restorationScopeId,
      requestFocus: requestFocus,
    );
  }

  /// Creates a [ARouter] with a dynamic [RoutingConfig].
  ARouter.routingConfig({
    required ValueListenable<RoutingConfig> routingConfig,
    Codec<Object?, Object?>? extraCodec,
    GoExceptionHandler? onException,
    ARouterPageBuilder? errorPageBuilder,
    ARouterWidgetBuilder? errorBuilder,
    Listenable? refreshListenable,
    bool routerNeglect = false,
    String? initialLocation,
    this.overridePlatformDefaultLocation = false,
    Object? initialExtra,
    List<NavigatorObserver>? observers,
    GlobalKey<NavigatorState>? navigatorKey,
    String? restorationScopeId,
    bool requestFocus = true,
  })  : _routingConfig = routingConfig,
        backButtonDispatcher = RootBackButtonDispatcher(),
        assert(
          initialExtra == null || initialLocation != null,
          'initialLocation must be set in order to use initialExtra',
        ),
        assert(!overridePlatformDefaultLocation || initialLocation != null,
            'Initial location must be set to override platform default'),
        assert(
            (onException == null ? 0 : 1) +
                    (errorPageBuilder == null ? 0 : 1) +
                    (errorBuilder == null ? 0 : 1) <
                2,
            'Only one of onException, errorPageBuilder, or errorBuilder can be provided.') {
    WidgetsFlutterBinding.ensureInitialized();

    navigatorKey ??= GlobalKey<NavigatorState>();

    _routingConfig.addListener(_handleRoutingConfigChanged);
    configuration = RouteConfiguration(
      _routingConfig,
      navigatorKey: navigatorKey,
      extraCodec: extraCodec,
    );

    final ParserExceptionHandler? parserExceptionHandler;
    if (onException != null) {
      parserExceptionHandler =
          (BuildContext context, RouteMatchList routeMatchList) {
        onException(context,
            configuration.buildTopLevelARouterState(routeMatchList), this);
        // Avoid updating ARouterDelegate if onException is provided.
        return routerDelegate.currentConfiguration;
      };
    } else {
      parserExceptionHandler = null;
    }

    routeInformationParser = ARouteInformationParser(
      onParserException: parserExceptionHandler,
      configuration: configuration,
    );

    routeInformationProvider = ARouteInformationProvider(
      initialLocation: _effectiveInitialLocation(initialLocation),
      initialExtra: initialExtra,
      refreshListenable: refreshListenable,
    );

    routerDelegate = ARouterDelegate(
      configuration: configuration,
      errorPageBuilder: errorPageBuilder,
      errorBuilder: errorBuilder,
      routerNeglect: routerNeglect,
      observers: [
        ...observers ?? [],
      ],
      restorationScopeId: restorationScopeId,
      requestFocus: requestFocus,
      // wrap the returned Navigator to enable ARouter.of(context).go() et al,
      // allowing the caller to wrap the navigator themselves
      builderWithNav: (BuildContext context, Widget child) =>
          InheritedARouter(router: this, child: child),
    );

    assert(() {
      configuration.log('Setting initial location: $initialLocation');
      return true;
    }());
  }

  /// Whether the imperative API affects browser URL bar.
  ///
  /// The Imperative APIs refer to [push], [pushReplacement], or [replace].
  ///
  /// If this option is set to true. The URL bar reflects the top-most [ARoute]
  /// regardless the [RouteBase]s underneath.
  ///
  /// If this option is set to false. The URL bar reflects the [RouteBase]s
  /// in the current state but ignores any [RouteBase]s that are results of
  /// imperative API calls.
  ///
  /// Defaults to false.
  ///
  /// This option is for backward compatibility. It is strongly suggested
  /// against setting this value to true, as the URL of the top-most [ARoute]
  /// is not always deeplink-able.
  ///
  /// This option only affects web platform.
  static bool optionURLReflectsImperativeAPIs = false;

  /// The route configuration used in go_router.
  late final RouteConfiguration configuration;

  @override
  final BackButtonDispatcher backButtonDispatcher;

  /// The router delegate. Provide this to the MaterialApp or CupertinoApp's
  /// `.router()` constructor
  @override
  late final ARouterDelegate routerDelegate;

  /// The route information provider used by [ARouter].
  @override
  late final ARouteInformationProvider routeInformationProvider;

  /// The route information parser used by [ARouter].
  @override
  late final ARouteInformationParser routeInformationParser;

  void _handleRoutingConfigChanged() {
    // Reparse is needed to update its builder
    restore(configuration.reparse(routerDelegate.currentConfiguration));
  }

  /// Whether to ignore platform's default initial location when
  /// `initialLocation` is set.
  ///
  /// When set to [true], the [initialLocation] will take
  /// precedence over the platform's default initial location.
  /// This allows developers to control the starting route of the application
  /// independently of the platform.
  ///
  /// Platform's initial location is set when the app opens via a deeplink.
  /// Use [overridePlatformDefaultLocation] only if one wants to override
  /// platform implemented initial location.
  ///
  /// Setting this parameter to [false] (default) will allow the platform's
  /// default initial location to be used even if the `initialLocation` is set.
  /// It's advisable to only set this to [true] if one explicitly wants to.
  final bool overridePlatformDefaultLocation;

  final ValueListenable<RoutingConfig> _routingConfig;

  /// Returns `true` if there is at least two or more route can be pop.
  bool canPop() => routerDelegate.canPop();

  /// Get a location from route name and parameters.
  /// This is useful for redirecting to a named location.
  String namedLocation(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
  }) =>
      configuration.namedLocation(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
      );

  /// Navigate to a URI location w/ optional query parameters, e.g.
  /// `/family/f2/person/p1?color=blue`
  void go(String location, {Object? extra}) {
    configuration.log('Going to location=$location');
    routeInformationProvider.go(location, extra: extra);
  }

  /// Restore the RouteMatchList
  void restore(RouteMatchList matchList) {
    configuration.log('Restoring uri=${matchList.uri}');
    routeInformationProvider.restore(
      matchList.uri.toString(),
      matchList: matchList,
    );
  }

  /// Navigate to a named route w/ optional parameters, e.g.
  /// `name='person', pathParameters={'fid': 'f2', 'pid': 'p1'}`
  /// Navigate to the named route.
  void goNamed(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) =>
      go(
        namedLocation(name,
            pathParameters: pathParameters, queryParameters: queryParameters),
        extra: extra,
      );

  /// Push a URI location onto the page stack w/ optional query parameters, e.g.
  /// `/family/f2/person/p1?color=blue`.
  ///
  /// See also:
  /// * [pushReplacement] which replaces the top-most page of the page stack and
  ///   always use a new page key.
  /// * [replace] which replaces the top-most page of the page stack but treats
  ///   it as the same page. The page key will be reused. This will preserve the
  ///   state and not run any page animation.
  Future<T?> push<T extends Object?>(String location, {Object? extra}) async {
    configuration.log('Pushing location=$location');
    return routeInformationProvider.push<T>(
      location,
      base: routerDelegate.currentConfiguration,
      extra: extra,
    );
  }

  /// Push a named route onto the page stack w/ optional parameters, e.g.
  /// `name='person', pathParameters={'fid': 'f2', 'pid': 'p1'}`
  Future<T?> pushNamed<T extends Object?>(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) =>
      push<T>(
        namedLocation(name,
            pathParameters: pathParameters, queryParameters: queryParameters),
        extra: extra,
      );

  /// Replaces the top-most page of the page stack with the given URL location
  /// w/ optional query parameters, e.g. `/family/f2/person/p1?color=blue`.
  ///
  /// See also:
  /// * [go] which navigates to the location.
  /// * [push] which pushes the given location onto the page stack.
  /// * [replace] which replaces the top-most page of the page stack but treats
  ///   it as the same page. The page key will be reused. This will preserve the
  ///   state and not run any page animation.
  Future<T?> pushReplacement<T extends Object?>(String location,
      {Object? extra}) {
    configuration.log('PushReplacement location=$location');
    return routeInformationProvider.pushReplacement<T>(
      location,
      base: routerDelegate.currentConfiguration,
      extra: extra,
    );
  }

  /// Replaces the top-most page of the page stack with the named route w/
  /// optional parameters, e.g. `name='person', pathParameters={'fid': 'f2', 'pid':
  /// 'p1'}`.
  ///
  /// See also:
  /// * [goNamed] which navigates a named route.
  /// * [pushNamed] which pushes a named route onto the page stack.
  Future<T?> pushReplacementNamed<T extends Object?>(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) {
    return pushReplacement<T>(
      namedLocation(name,
          pathParameters: pathParameters, queryParameters: queryParameters),
      extra: extra,
    );
  }

  /// Replaces the top-most page of the page stack with the given one but treats
  /// it as the same page.
  ///
  /// The page key will be reused. This will preserve the state and not run any
  /// page animation.
  ///
  /// See also:
  /// * [push] which pushes the given location onto the page stack.
  /// * [pushReplacement] which replaces the top-most page of the page stack but
  ///   always uses a new page key.
  Future<T?> replace<T>(String location, {Object? extra}) {
    configuration.log('Replace location=$location');
    return routeInformationProvider.replace<T>(
      location,
      base: routerDelegate.currentConfiguration,
      extra: extra,
    );
  }

  /// Replaces the top-most page with the named route and optional parameters,
  /// preserving the page key.
  ///
  /// This will preserve the state and not run any page animation. Optional
  /// parameters can be provided to the named route, e.g. `name='person',
  /// pathParameters={'fid': 'f2', 'pid': 'p1'}`.
  ///
  /// See also:
  /// * [pushNamed] which pushes the given location onto the page stack.
  /// * [pushReplacementNamed] which replaces the top-most page of the page
  ///   stack but always uses a new page key.
  Future<T?> replaceNamed<T>(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Object? extra,
  }) {
    return replace(
      namedLocation(name,
          pathParameters: pathParameters, queryParameters: queryParameters),
      extra: extra,
    );
  }

  /// Pop the top-most route off the current screen.
  ///
  /// If the top-most route is a pop up or dialog, this method pops it instead
  /// of any ARoute under it.
  void pop<T extends Object?>([T? result]) {
    assert(() {
      configuration.log('Popping uri=${routerDelegate.currentConfiguration.uri}');
      return true;
    }());
    routerDelegate.pop<T>(result);
  }

  /// Refresh the route.
  void refresh() {
    assert(() {
      configuration.log('Refreshing uri=${routerDelegate.currentConfiguration.uri}');
      return true;
    }());
    routeInformationProvider.notifyListeners();
  }

  /// Find the current ARouter in the widget tree.
  ///
  /// This method throws when it is called during redirects.
  static ARouter of(BuildContext context) {
    final ARouter? inherited = maybeOf(context);
    assert(inherited != null, 'No ARouter found in context');
    return inherited!;
  }

  /// The current ARouter in the widget tree, if any.
  ///
  /// This method returns null when it is called during redirects.
  static ARouter? maybeOf(BuildContext context) {
    final InheritedARouter? inherited = context
        .getElementForInheritedWidgetOfExactType<InheritedARouter>()
        ?.widget as InheritedARouter?;
    return inherited?.router;
  }

  /// Disposes resource created by this object.
  void dispose() {
    _routingConfig.removeListener(_handleRoutingConfigChanged);
    routeInformationProvider.dispose();
    routerDelegate.dispose();
  }

  String _effectiveInitialLocation(String? initialLocation) {
    if (overridePlatformDefaultLocation) {
      // The initialLocation must not be null as it's already
      // verified by assert() during the initialization.
      return initialLocation!;
    }
    Uri platformDefaultUri = Uri.parse(
      WidgetsBinding.instance.platformDispatcher.defaultRouteName,
    );
    if (platformDefaultUri.hasEmptyPath) {
      platformDefaultUri = Uri(
        path: '/',
        queryParameters: platformDefaultUri.queryParameters,
      );
    }
    final String platformDefault = platformDefaultUri.toString();
    if (initialLocation == null) {
      return platformDefault;
    } else if (platformDefault == '/') {
      return initialLocation;
    } else {
      return platformDefault;
    }
  }
}
