import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:meta/meta_meta.dart';

import 'route.dart';
import 'state.dart';

/// Baseclass for supporting
abstract class RouteData {
  /// Allows subclasses to have `const` constructors.
  const RouteData();
}

/// A class to represent a [ARoute] in
///
/// Subclasses must override one of [build], [buildPage], or
/// [redirect].
/// {@category Type-safe routes}
abstract class ARouteData extends RouteData {
  /// Allows subclasses to have `const` constructors.
  ///
  /// [ARouteData] is abstract and cannot be instantiated directly.
  const ARouteData();

  /// Creates the [Widget] for `this` route.
  ///
  /// Subclasses must override one of [build], [buildPage], or
  /// [redirect].
  ///
  /// Corresponds to [ARoute.builder].
  Widget build(BuildContext context, ARouterState state) =>
      throw UnimplementedError(
        'One of `build` or `buildPage` must be implemented.',
      );

  /// A page builder for this route.
  ///
  /// Subclasses can override this function to provide a custom [Page].
  ///
  /// Subclasses must override one of [build], [buildPage] or
  /// [redirect].
  ///
  /// Corresponds to [ARoute.pageBuilder].
  ///
  /// By default, returns a [Page] instance that is ignored, causing a default
  /// [Page] implementation to be used with the results of [build].
  Page<void> buildPage(BuildContext context, ARouterState state) =>
      const NoOpPage();

  /// An optional redirect function for this route.
  ///
  /// Subclasses must override one of [build], [buildPage], or
  /// [redirect].
  ///
  /// Corresponds to [ARoute.redirect].
  FutureOr<String?> redirect(BuildContext context, ARouterState state) => null;

  /// Called when this route is removed from ARouter's route history.
  ///
  /// Corresponds to [ARoute.onExit].
  FutureOr<bool> onExit(BuildContext context, ARouterState state) => true;

  /// A helper function used by generated code.
  ///
  /// Should not be used directly.
  static String $location(String path, {Map<String, dynamic>? queryParams}) =>
      Uri.parse(path)
          .replace(
            queryParameters:
                // Avoid `?` in generated location if `queryParams` is empty
                queryParams?.isNotEmpty ?? false ? queryParams : null,
          )
          .toString();

  /// A helper function used by generated code.
  ///
  /// Should not be used directly.
  static ARoute $route<T extends ARouteData>({
    required String path,
    String? name,
    required T Function(ARouterState) factory,
    GlobalKey<NavigatorState>? parentNavigatorKey,
    List<RouteBase> routes = const <RouteBase>[],
  }) {
    T factoryImpl(ARouterState state) {
      final Object? extra = state.extra;

      // If the "extra" value is of type `T` then we know it's the source
      // instance of `ARouteData`, so it doesn't need to be recreated.
      if (extra is T) {
        return extra;
      }

      return (_stateObjectExpando[state] ??= factory(state)) as T;
    }

    Widget builder(BuildContext context, ARouterState state) =>
        factoryImpl(state).build(context, state);

    Page<void> pageBuilder(BuildContext context, ARouterState state) =>
        factoryImpl(state).buildPage(context, state);

    FutureOr<String?> redirect(BuildContext context, ARouterState state) =>
        factoryImpl(state).redirect(context, state);

    FutureOr<bool> onExit(BuildContext context, ARouterState state) =>
        factoryImpl(state).onExit(context, state);

    return ARoute(
      path: path,
      name: name,
      builder: builder,
      pageBuilder: pageBuilder,
      redirect: redirect,
      routes: routes,
      parentNavigatorKey: parentNavigatorKey,
      onExit: onExit,
    );
  }

  /// Used to cache [ARouteData] that corresponds to a given [ARouterState]
  /// to minimize the number of times it has to be deserialized.
  static final Expando<ARouteData> _stateObjectExpando = Expando<ARouteData>(
    'ARouteState to ARouteData expando',
  );
}

/// A class to represent a [ShellRoute] in
abstract class ShellRouteData extends RouteData {
  /// Allows subclasses to have `const` constructors.
  ///
  /// [ShellRouteData] is abstract and cannot be instantiated directly.
  const ShellRouteData();

  /// [pageBuilder] is used to build the page
  Page<void> pageBuilder(
    BuildContext context,
    ARouterState state,
    Widget navigator,
  ) =>
      const NoOpPage();

  /// [builder] is used to build the widget
  Widget builder(
    BuildContext context,
    ARouterState state,
    Widget navigator,
  ) =>
      throw UnimplementedError(
        'One of `builder` or `pageBuilder` must be implemented.',
      );

  /// An optional redirect function for this route.
  ///
  /// Subclasses must override one of [build], [buildPage], or
  /// [redirect].
  ///
  /// Corresponds to [ARoute.redirect].
  FutureOr<String?> redirect(BuildContext context, ARouterState state) => null;

  /// A helper function used by generated code.
  ///
  /// Should not be used directly.
  static ShellRoute $route<T extends ShellRouteData>({
    required T Function(ARouterState) factory,
    GlobalKey<NavigatorState>? navigatorKey,
    GlobalKey<NavigatorState>? parentNavigatorKey,
    List<RouteBase> routes = const <RouteBase>[],
    List<NavigatorObserver>? observers,
    String? restorationScopeId,
  }) {
    T factoryImpl(ARouterState state) {
      return (_stateObjectExpando[state] ??= factory(state)) as T;
    }

    FutureOr<String?> redirect(BuildContext context, ARouterState state) =>
        factoryImpl(state).redirect(context, state);

    Widget builder(
      BuildContext context,
      ARouterState state,
      Widget navigator,
    ) =>
        factoryImpl(state).builder(
          context,
          state,
          navigator,
        );

    Page<void> pageBuilder(
      BuildContext context,
      ARouterState state,
      Widget navigator,
    ) =>
        factoryImpl(state).pageBuilder(
          context,
          state,
          navigator,
        );

    return ShellRoute(
      builder: builder,
      pageBuilder: pageBuilder,
      parentNavigatorKey: parentNavigatorKey,
      routes: routes,
      navigatorKey: navigatorKey,
      observers: observers,
      restorationScopeId: restorationScopeId,
      redirect: redirect,
    );
  }

  /// Used to cache [ShellRouteData] that corresponds to a given [ARouterState]
  /// to minimize the number of times it has to be deserialized.
  static final Expando<ShellRouteData> _stateObjectExpando =
      Expando<ShellRouteData>(
    'ARouteState to ShellRouteData expando',
  );
}

/// Base class for supporting
abstract class StatefulShellRouteData extends RouteData {
  /// Default const constructor
  const StatefulShellRouteData();

  /// An optional redirect function for this route.
  ///
  /// Subclasses must override one of [build], [buildPage], or
  /// [redirect].
  ///
  /// Corresponds to [ARoute.redirect].
  FutureOr<String?> redirect(BuildContext context, ARouterState state) => null;

  /// [pageBuilder] is used to build the page
  Page<void> pageBuilder(
    BuildContext context,
    ARouterState state,
    StatefulNavigationShell navigationShell,
  ) =>
      const NoOpPage();

  /// [builder] is used to build the widget
  Widget builder(
    BuildContext context,
    ARouterState state,
    StatefulNavigationShell navigationShell,
  ) =>
      throw UnimplementedError(
        'One of `builder` or `pageBuilder` must be implemented.',
      );

  /// A helper function used by generated code.
  ///
  /// Should not be used directly.
  static StatefulShellRoute $route<T extends StatefulShellRouteData>({
    required T Function(ARouterState) factory,
    required List<StatefulShellBranch> branches,
    GlobalKey<NavigatorState>? parentNavigatorKey,
    ShellNavigationContainerBuilder? navigatorContainerBuilder,
    String? restorationScopeId,
  }) {
    T factoryImpl(ARouterState state) {
      return (_stateObjectExpando[state] ??= factory(state)) as T;
    }

    Widget builder(
      BuildContext context,
      ARouterState state,
      StatefulNavigationShell navigationShell,
    ) =>
        factoryImpl(state).builder(
          context,
          state,
          navigationShell,
        );

    Page<void> pageBuilder(
      BuildContext context,
      ARouterState state,
      StatefulNavigationShell navigationShell,
    ) =>
        factoryImpl(state).pageBuilder(
          context,
          state,
          navigationShell,
        );

    FutureOr<String?> redirect(BuildContext context, ARouterState state) =>
        factoryImpl(state).redirect(context, state);

    if (navigatorContainerBuilder != null) {
      return StatefulShellRoute(
        branches: branches,
        builder: builder,
        pageBuilder: pageBuilder,
        navigatorContainerBuilder: navigatorContainerBuilder,
        parentNavigatorKey: parentNavigatorKey,
        restorationScopeId: restorationScopeId,
        redirect: redirect,
      );
    }
    return StatefulShellRoute.indexedStack(
      branches: branches,
      builder: builder,
      pageBuilder: pageBuilder,
      parentNavigatorKey: parentNavigatorKey,
      restorationScopeId: restorationScopeId,
      redirect: redirect,
    );
  }

  /// Used to cache [StatefulShellRouteData] that corresponds to a given [ARouterState]
  /// to minimize the number of times it has to be deserialized.
  static final Expando<StatefulShellRouteData> _stateObjectExpando =
      Expando<StatefulShellRouteData>(
    'ARouteState to StatefulShellRouteData expando',
  );
}

/// Base class for supporting
abstract class StatefulShellBranchData {
  /// Default const constructor
  const StatefulShellBranchData();

  /// A helper function used by generated code.
  ///
  /// Should not be used directly.
  static StatefulShellBranch $branch<T extends StatefulShellBranchData>({
    GlobalKey<NavigatorState>? navigatorKey,
    List<RouteBase> routes = const <RouteBase>[],
    List<NavigatorObserver>? observers,
    String? initialLocation,
    String? restorationScopeId,
  }) {
    return StatefulShellBranch(
      routes: routes,
      navigatorKey: navigatorKey,
      observers: observers,
      initialLocation: initialLocation,
      restorationScopeId: restorationScopeId,
    );
  }
}

/// A superclass for each typed route descendant
class TypedRoute<T extends RouteData> {
  /// Default const constructor
  const TypedRoute();
}

/// A superclass for each typed go route descendant
@Target(<TargetKind>{TargetKind.library, TargetKind.classType})
class TypedARoute<T extends ARouteData> extends TypedRoute<T> {
  /// Default const constructor
  const TypedARoute({
    required this.path,
    this.name,
    this.routes = const <TypedRoute<RouteData>>[],
  });

  /// The path that corresponds to this route.
  ///
  /// See [ARoute.path].
  ///
  ///
  final String path;

  /// The name that corresponds to this route.
  /// Used by Analytics services such as Firebase Analytics
  /// to log the screen views in their system.
  ///
  /// See [ARoute.name].
  ///
  final String? name;

  /// Child route definitions.
  ///
  /// See [RouteBase.routes].
  final List<TypedRoute<RouteData>> routes;
}

/// A superclass for each typed shell route descendant
@Target(<TargetKind>{TargetKind.library, TargetKind.classType})
class TypedShellRoute<T extends ShellRouteData> extends TypedRoute<T> {
  /// Default const constructor
  const TypedShellRoute({
    this.routes = const <TypedRoute<RouteData>>[],
  });

  /// Child route definitions.
  ///
  /// See [RouteBase.routes].
  final List<TypedRoute<RouteData>> routes;
}

/// A superclass for each typed shell route descendant
@Target(<TargetKind>{TargetKind.library, TargetKind.classType})
class TypedStatefulShellRoute<T extends StatefulShellRouteData>
    extends TypedRoute<T> {
  /// Default const constructor
  const TypedStatefulShellRoute({
    this.branches = const <TypedStatefulShellBranch<StatefulShellBranchData>>[],
  });

  /// Child route definitions.
  ///
  /// See [RouteBase.routes].
  final List<TypedStatefulShellBranch<StatefulShellBranchData>> branches;
}

/// A superclass for each typed shell route descendant
@Target(<TargetKind>{TargetKind.library, TargetKind.classType})
class TypedStatefulShellBranch<T extends StatefulShellBranchData> {
  /// Default const constructor
  const TypedStatefulShellBranch({
    this.routes = const <TypedRoute<RouteData>>[],
  });

  /// Child route definitions.
  ///
  /// See [RouteBase.routes].
  final List<TypedRoute<RouteData>> routes;
}

/// Internal class used to signal that the default page behavior should be used.
class NoOpPage extends Page<void> {
  /// Creates an instance of NoOpPage;
  const NoOpPage();

  @override
  Route<void> createRoute(BuildContext context) =>
      throw UnsupportedError('Should never be called');
}
