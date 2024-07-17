import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'configuration.dart';
import 'misc/errors.dart';
import 'route.dart';

/// The route state during routing.
///
/// The state contains parsed artifacts of the current URI.
@immutable
class ARouterState {
  /// Default constructor for creating route state during routing.
  const ARouterState(
    this._configuration, {
    required this.uri,
    required this.matchedLocation,
    this.name,
    this.path,
    required this.fullPath,
    required this.pathParameters,
    this.extra,
    this.error,
    required this.pageKey,
    this.topRoute,
  });
  final RouteConfiguration _configuration;

  /// The full uri of the route, e.g. /family/f2/person/p1?filter=name#fragment
  final Uri uri;

  /// The matched location until this point.
  ///
  /// For example:
  ///
  /// location = /family/f2/person/p1
  /// route = ARoute('/family/:id')
  ///
  /// matchedLocation = /family/f2
  final String matchedLocation;

  /// The optional name of the route associated with this app.
  ///
  /// This can be null for ARouterState pass into top level redirect.
  final String? name;

  /// The path of the route associated with this app. e.g. family/:fid
  ///
  /// This can be null for ARouterState pass into top level redirect.
  final String? path;

  /// The full path to this sub-route, e.g. /family/:fid
  ///
  /// For top level redirect, this is the entire path that matches the location.
  /// It can be empty if go router can't find a match. In that case, the [error]
  /// contains more information.
  final String? fullPath;

  /// The parameters for this match, e.g. {'fid': 'f2'}
  final Map<String, String> pathParameters;

  /// An extra object to pass along with the navigation.
  final Object? extra;

  /// The error associated with this sub-route.
  final GoException? error;

  /// A unique string key for this sub-route.
  /// E.g.
  /// ```dart
  /// ValueKey('/family/:fid')
  /// ```
  final ValueKey<String> pageKey;

  /// The current matched top route associated with this state.
  ///
  /// If this state represents a [ShellRoute], the top [ARoute] will be the current
  /// matched location associated with the [ShellRoute]. This allows the [ShellRoute]'s
  /// associated ARouterState to be uniquely identified using [ARoute.name]
  final ARoute? topRoute;

  /// Gets the [ARouterState] from context.
  ///
  /// The returned [ARouterState] will depends on which [ARoute] or
  /// [ShellRoute] the input `context` is in.
  ///
  /// This method only supports [ARoute] and [ShellRoute] that generate
  /// [ModalRoute]s. This is typically the case if one uses [ARoute.builder],
  /// [ShellRoute.builder], [CupertinoPage], [MaterialPage],
  /// [CustomTransitionPage], or [NoTransitionPage].
  ///
  /// This method is fine to be called during [ARoute.builder] or
  /// [ShellRoute.builder].
  ///
  /// This method cannot be called during [ARoute.pageBuilder] or
  /// [ShellRoute.pageBuilder] since there is no [ARouterState] to be
  /// associated with.
  ///
  /// To access ARouterState from a widget.
  ///
  /// ```
  /// ARoute(
  ///   path: '/:id'
  ///   builder: (_, __) => MyWidget(),
  /// );
  ///
  /// class MyWidget extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return Text('${ARouterState.of(context).pathParameters['id']}');
  ///   }
  /// }
  /// ```
  static ARouterState of(BuildContext context) {
    final ModalRoute<Object?>? route = ModalRoute.of(context);
    if (route == null) {
      throw GoError('There is no modal route above the current context.');
    }
    final RouteSettings settings = route.settings;
    if (settings is! Page<Object?>) {
      throw GoError(
          'The parent route must be a page route to have a ARouterState');
    }
    final ARouterStateRegistryScope? scope = context
        .dependOnInheritedWidgetOfExactType<ARouterStateRegistryScope>();
    if (scope == null) {
      throw GoError(
          'There is no ARouterStateRegistryScope above the current context.');
    }
    final ARouterState state =
        scope.notifier!._createPageRouteAssociation(settings, route);
    return state;
  }

  /// Get a location from route name and parameters.
  /// This is useful for redirecting to a named location.
  String namedLocation(
    String name, {
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
  }) {
    return _configuration.namedLocation(name,
        pathParameters: pathParameters, queryParameters: queryParameters);
  }

  @override
  bool operator ==(Object other) {
    return other is ARouterState &&
        other.uri == uri &&
        other.matchedLocation == matchedLocation &&
        other.name == name &&
        other.path == path &&
        other.fullPath == fullPath &&
        other.pathParameters == pathParameters &&
        other.extra == extra &&
        other.error == error &&
        other.pageKey == pageKey;
  }

  @override
  int get hashCode => Object.hash(
        uri,
        matchedLocation,
        name,
        path,
        fullPath,
        pathParameters,
        extra,
        error,
        pageKey,
      );
}

/// An inherited widget to host a [ARouterStateRegistry] for the subtree.
///
/// Should not be used directly, consider using [ARouterState.of] to access
/// [ARouterState] from the context.
@internal
class ARouterStateRegistryScope
    extends InheritedNotifier<ARouterStateRegistry> {
  /// Creates a ARouterStateRegistryScope.
  const ARouterStateRegistryScope({
    super.key,
    required ARouterStateRegistry registry,
    required super.child,
  }) : super(notifier: registry);
}

/// A registry to record [ARouterState] to [Page] relation.
///
/// Should not be used directly, consider using [ARouterState.of] to access
/// [ARouterState] from the context.
@internal
class ARouterStateRegistry extends ChangeNotifier {
  /// creates a [ARouterStateRegistry].
  ARouterStateRegistry();

  /// A [Map] that maps a [Page] to a [ARouterState].
  @visibleForTesting
  final Map<Page<Object?>, ARouterState> registry =
      <Page<Object?>, ARouterState>{};

  final Map<Route<Object?>, Page<Object?>> _routePageAssociation =
      <ModalRoute<Object?>, Page<Object?>>{};

  ARouterState _createPageRouteAssociation(
      Page<Object?> page, ModalRoute<Object?> route) {
    assert(route.settings == page);
    assert(registry.containsKey(page));
    final Page<Object?>? oldPage = _routePageAssociation[route];
    if (oldPage == null) {
      // This is a new association.
      _routePageAssociation[route] = page;
      // If there is an association, the registry relies on the route to remove
      // entry from registry because it wants to preserve the ARouterState
      // until the route finishes the popping animations.
      route.completed.then<void>((Object? result) {
        // Can't use `page` directly because Route.settings may have changed during
        // the lifetime of this route.
        final Page<Object?> associatedPage =
            _routePageAssociation.remove(route)!;
        assert(registry.containsKey(associatedPage));
        registry.remove(associatedPage);
      });
    } else if (oldPage != page) {
      // Need to update the association to avoid memory leak.
      _routePageAssociation[route] = page;
      assert(registry.containsKey(oldPage));
      registry.remove(oldPage);
    }
    assert(_routePageAssociation[route] == page);
    return registry[page]!;
  }

  /// Updates this registry with new records.
  void updateRegistry(Map<Page<Object?>, ARouterState> newRegistry) {
    bool shouldNotify = false;
    final Set<Page<Object?>> pagesWithAssociation =
        _routePageAssociation.values.toSet();
    for (final MapEntry<Page<Object?>, ARouterState> entry
        in newRegistry.entries) {
      final ARouterState? existingState = registry[entry.key];
      if (existingState != null) {
        if (existingState != entry.value) {
          shouldNotify =
              shouldNotify || pagesWithAssociation.contains(entry.key);
          registry[entry.key] = entry.value;
        }
        continue;
      }
      // Not in the _registry.
      registry[entry.key] = entry.value;
      // Adding or removing registry does not need to notify the listen since
      // no one should be depending on them.
    }
    registry.removeWhere((Page<Object?> key, ARouterState value) {
      if (newRegistry.containsKey(key)) {
        return false;
      }
      // For those that have page route association, it will be removed by the
      // route future. Need to notify the listener so they can update the page
      // route association if its page has changed.
      if (pagesWithAssociation.contains(key)) {
        shouldNotify = true;
        return false;
      }
      return true;
    });
    if (shouldNotify) {
      notifyListeners();
    }
  }
}
