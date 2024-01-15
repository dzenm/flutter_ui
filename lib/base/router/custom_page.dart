import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

///
/// Created by a0010 on 2023/7/5 16:22
///
typedef BuildCustomRoute<T extends Object?> = Route<T> Function(BuildContext context, CustomPage page);

PageTransitionsBuilder defaultTransitionsBuilder() {
  if (kIsWeb) return const NoTransitionBuilder();
  switch (Platform.operatingSystem) {
    case 'android':
    case 'fuchsia':
    case 'windows':
      return const OpenUpwardsPageTransitionsBuilder();
    case 'ios':
    case 'macos':
    case 'linux':
      return const CupertinoPageTransitionsBuilder();
  }
  return const OpenUpwardsPageTransitionsBuilder();
}

class CustomPage<T extends Object?> extends Page<T> {
  CustomPage({
    required this.child,
    required this.buildCustomRoute,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.barrierColor,
    this.barrierLabel,
    this.opaque = true,
    this.filter,
    this.semanticsDismissible = true,
    this.barrierDismissible = true,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  })  : completerResult = Completer();

  final BuildCustomRoute<T> buildCustomRoute;

  /// The content to be shown in the [Route] created by this page.
  final Widget child;

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  final Completer completerResult;

  final Duration transitionDuration;

  final Color? barrierColor;

  final String? barrierLabel;

  final bool opaque;

  final ui.ImageFilter? filter;

  final bool semanticsDismissible;

  final bool barrierDismissible;

  @override
  Route<T> createRoute(BuildContext context) {
    return buildCustomRoute(context, this);
  }
}

/// Navigator 2.0
class DefaultPageRoute2<T> extends PageRoute<T> {
  DefaultPageRoute2({
    required CustomPage<T> page,
    this.pageTransitionsBuilder,
  }) : super(settings: page);
  final PageTransitionsBuilder? pageTransitionsBuilder;

  CustomPage<T> get _page => settings as CustomPage<T>;

  Widget buildContent(BuildContext context) {
    return _page.child;
  }

  @override
  ui.ImageFilter? get filter => _page.filter;

  @override
  bool get opaque => _page.opaque;

  @override
  Color? get barrierColor => _page.barrierColor;

  @override
  String? get barrierLabel => _page.barrierLabel;

  @override
  bool get barrierDismissible => _page.barrierDismissible;

  @override
  bool get semanticsDismissible => _page.semanticsDismissible;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';

  @override
  Duration get transitionDuration => _page.transitionDuration;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final Widget result = buildContent(context);
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: result,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    if (pageTransitionsBuilder == null) {
      return child;
    }
    return pageTransitionsBuilder!.buildTransitions<T>(this, context, animation, secondaryAnimation, child);
  }
}

mixin CustomRouteTransitionMixin<T> on PageRoute<T> {
  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog.
    return (nextRoute is CustomRouteTransitionMixin && !nextRoute.fullscreenDialog) || (nextRoute is CupertinoRouteTransitionMixin && !nextRoute.fullscreenDialog);
  }
}

class PageBasedCustomPageRoute = DefaultPageRoute2 with CustomRouteTransitionMixin;

class CupertinoModalPopupRoute2 = DefaultPageRoute2 with CupertinoModalPopupRouteMixin;

mixin CupertinoModalPopupRouteMixin<T> on PageRoute<T> {
  Animation<double>? _animation;

  late Tween<Offset> _offsetTween;

  Widget buildContent(BuildContext context);

  @override
  Animation<double> createAnimation() {
    assert(_animation == null);
    _animation = CurvedAnimation(
      parent: super.createAnimation(),

      // These curves were initially measured from native iOS horizontal page
      // route animations and seemed to be a good match here as well.
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.linearToEaseOut.flipped,
    );
    _offsetTween = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    );
    return _animation!;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return CupertinoUserInterfaceLevel(
      data: CupertinoUserInterfaceLevelData.elevated,
      child: Builder(builder: buildContent),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionalTranslation(
        translation: _offsetTween.evaluate(_animation!),
        child: child,
      ),
    );
  }
}

/// if run web, this transition will be default.
class NoTransitionBuilder extends PageTransitionsBuilder {
  const NoTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}