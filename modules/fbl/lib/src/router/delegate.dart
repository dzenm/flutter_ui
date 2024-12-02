import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'builder.dart';
import 'configuration.dart';
import 'match.dart';
import 'misc/errors.dart';
import 'route.dart';

/// ARouter implementation of [RouterDelegate].
class ARouterDelegate extends RouterDelegate<RouteMatchList>
    with ChangeNotifier {
  /// Constructor for ARouter's implementation of the RouterDelegate base
  /// class.
  ARouterDelegate({
    required RouteConfiguration configuration,
    required ARouterBuilderWithNav builderWithNav,
    required ARouterPageBuilder? errorPageBuilder,
    required ARouterWidgetBuilder? errorBuilder,
    required List<NavigatorObserver> observers,
    required this.routerNeglect,
    String? restorationScopeId,
    bool requestFocus = true,
  }) : _configuration = configuration {
    builder = RouteBuilder(
      configuration: configuration,
      builderWithNav: builderWithNav,
      errorPageBuilder: errorPageBuilder,
      errorBuilder: errorBuilder,
      restorationScopeId: restorationScopeId,
      observers: observers,
      onPopPageWithRouteMatch: _handlePopPageWithRouteMatch,
      requestFocus: requestFocus,
    );
  }

  /// Builds the top-level Navigator given a configuration and location.
  @visibleForTesting
  late final RouteBuilder builder;

  /// Set to true to disable creating history entries on the web.
  final bool routerNeglect;

  final RouteConfiguration _configuration;

  @override
  Future<bool> popRoute() async {
    NavigatorState? state = navigatorKey.currentState;
    if (state == null) {
      return false;
    }
    if (!state.canPop()) {
      state = null;
    }
    RouteMatchBase walker = currentConfiguration.matches.last;
    while (walker is ShellRouteMatch) {
      if (walker.navigatorKey.currentState?.canPop() ?? false) {
        state = walker.navigatorKey.currentState;
      }
      walker = walker.matches.last;
    }
    assert(walker is RouteMatch);
    if (state != null) {
      return state.maybePop();
    }
    // This should be the only place where the last ARoute exit the screen.
    final ARoute lastRoute = currentConfiguration.last.route;
    if (lastRoute.onExit != null && navigatorKey.currentContext != null) {
      return !(await lastRoute.onExit!(
        navigatorKey.currentContext!,
        walker.buildState(_configuration, currentConfiguration),
      ));
    }
    return false;
  }

  /// Returns `true` if the active Navigator can pop.
  bool canPop() {
    if (navigatorKey.currentState?.canPop() ?? false) {
      return true;
    }
    RouteMatchBase walker = currentConfiguration.matches.last;
    while (walker is ShellRouteMatch) {
      if (walker.navigatorKey.currentState?.canPop() ?? false) {
        return true;
      }
      walker = walker.matches.last;
    }
    return false;
  }

  /// Pops the top-most route.
  void pop<T extends Object?>([T? result]) {
    NavigatorState? state;
    if (navigatorKey.currentState?.canPop() ?? false) {
      state = navigatorKey.currentState;
    }
    RouteMatchBase walker = currentConfiguration.matches.last;
    while (walker is ShellRouteMatch) {
      if (walker.navigatorKey.currentState?.canPop() ?? false) {
        state = walker.navigatorKey.currentState;
      }
      walker = walker.matches.last;
    }
    if (state == null) {
      throw GoError('There is nothing to pop');
    }
    state.pop(result);
  }

  void _debugAssertMatchListNotEmpty() {
    assert(
      currentConfiguration.isNotEmpty,
      'You have popped the last page off of the stack,'
      ' there are no pages left to show',
    );
  }

  bool _handlePopPageWithRouteMatch(
      Route<Object?> route, Object? result, RouteMatchBase match) {
    if (route.willHandlePopInternally) {
      final bool popped = route.didPop(result);
      assert(!popped);
      return popped;
    }
    final RouteBase routeBase = match.route;
    if (routeBase is! ARoute || routeBase.onExit == null) {
      route.didPop(result);
      _completeRouteMatch(result, match);
      return true;
    }

    // The _handlePopPageWithRouteMatch is called during draw frame, schedule
    // a microtask in case the onExit callback want to launch dialog or other
    // navigator operations.
    scheduleMicrotask(() async {
      final bool onExitResult = await routeBase.onExit!(
        navigatorKey.currentContext!,
        match.buildState(_configuration, currentConfiguration),
      );
      if (onExitResult) {
        _completeRouteMatch(result, match);
      }
    });
    return false;
  }

  void _completeRouteMatch(Object? result, RouteMatchBase match) {
    RouteMatchBase walker = match;
    while (walker is ShellRouteMatch) {
      walker = walker.matches.last;
    }
    if (walker is ImperativeRouteMatch) {
      walker.complete(result);
    }
    currentConfiguration = currentConfiguration.remove(match);
    notifyListeners();
    assert(() {
      _debugAssertMatchListNotEmpty();
      return true;
    }());
  }

  /// For use by the Router architecture as part of the RouterDelegate.
  GlobalKey<NavigatorState> get navigatorKey => _configuration.navigatorKey;

  /// For use by the Router architecture as part of the RouterDelegate.
  @override
  RouteMatchList currentConfiguration = RouteMatchList.empty;

  /// For use by the Router architecture as part of the RouterDelegate.
  @override
  Widget build(BuildContext context) {
    return builder.build(
      context,
      currentConfiguration,
      routerNeglect,
    );
  }

  /// For use by the Router architecture as part of the RouterDelegate.
  // This class avoids using async to make sure the route is processed
  // synchronously if possible.
  @override
  Future<void> setNewRoutePath(RouteMatchList configuration) {
    if (currentConfiguration == configuration) {
      return SynchronousFuture<void>(null);
    }

    assert(configuration.isNotEmpty || configuration.isError);

    final BuildContext? navigatorContext = navigatorKey.currentContext;
    // If navigator is not built or disposed, the ARoute.onExit is irrelevant.
    if (navigatorContext != null) {
      final List<RouteMatch> currentARouteMatches = <RouteMatch>[];
      currentConfiguration.visitRouteMatches((RouteMatchBase match) {
        if (match is RouteMatch) {
          currentARouteMatches.add(match);
        }
        return true;
      });
      final List<RouteMatch> newARouteMatches = <RouteMatch>[];
      configuration.visitRouteMatches((RouteMatchBase match) {
        if (match is RouteMatch) {
          newARouteMatches.add(match);
        }
        return true;
      });

      final int compareUntil = math.min(
        currentARouteMatches.length,
        newARouteMatches.length,
      );
      int indexOfFirstDiff = 0;
      for (; indexOfFirstDiff < compareUntil; indexOfFirstDiff++) {
        if (currentARouteMatches[indexOfFirstDiff] !=
            newARouteMatches[indexOfFirstDiff]) {
          break;
        }
      }

      if (indexOfFirstDiff < currentARouteMatches.length) {
        final List<RouteMatch> exitingMatches =
            currentARouteMatches.sublist(indexOfFirstDiff).toList();
        return _callOnExitStartsAt(
          exitingMatches.length - 1,
          context: navigatorContext,
          matches: exitingMatches,
        ).then<void>((bool exit) {
          if (!exit) {
            return SynchronousFuture<void>(null);
          }
          return _setCurrentConfiguration(configuration);
        });
      }
    }

    return _setCurrentConfiguration(configuration);
  }

  /// Calls [ARoute.onExit] starting from the index
  ///
  /// The returned future resolves to true if all routes below the index all
  /// return true. Otherwise, the returned future resolves to false.
  Future<bool> _callOnExitStartsAt(
    int index, {
    required BuildContext context,
    required List<RouteMatch> matches,
  }) {
    if (index < 0) {
      return SynchronousFuture<bool>(true);
    }
    final RouteMatch match = matches[index];
    final ARoute route = match.route;
    if (route.onExit == null) {
      return _callOnExitStartsAt(
        index - 1,
        context: context,
        matches: matches,
      );
    }

    Future<bool> handleOnExitResult(bool exit) {
      if (exit) {
        return _callOnExitStartsAt(
          index - 1,
          context: context,
          matches: matches,
        );
      }
      return SynchronousFuture<bool>(false);
    }

    final FutureOr<bool> exitFuture = route.onExit!(
      context,
      match.buildState(_configuration, currentConfiguration),
    );
    if (exitFuture is bool) {
      return handleOnExitResult(exitFuture);
    }
    return exitFuture.then<bool>(handleOnExitResult);
  }

  Future<void> _setCurrentConfiguration(RouteMatchList configuration) {
    currentConfiguration = configuration;
    notifyListeners();
    return SynchronousFuture<void>(null);
  }
}
